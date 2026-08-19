# Week 3 – OCI Terraform Modules + OKE Lab

## Repo layout

```
oci-terraform-oke/
├── modules/
│   ├── subnet/        # generic Subnet + Route Table + Security List + (optional) Flow Log
│   └── oke/            # generic OKE cluster + managed node pool (VCN-native pod networking)
├── environments/
│   └── dev/             # ONLY place with real values (CIDRs, names, tags) — calls both modules
└── k8s/                 # manifests for the lab: namespace, PVC, Deployment, LoadBalancer Service
```

The rule followed throughout: **modules never contain a literal value that could plausibly
differ between environments.** Every CIDR, name, flag, and OCID is a variable. `environments/dev`
is the only file where real numbers appear — that's what makes the modules "reusable."

---

## 1. Concepts you asked to research (quick reference)

### Dynamic blocks
Used when a nested block inside a resource needs to repeat a variable number of times
(0, 1, or many) based on a list/map passed into the module. Pattern:

```hcl
dynamic "block_name" {
  for_each = var.some_list
  content {
    field = block_name.value.some_field
  }
}
```

Used in this repo for:
- Security list `ingress_security_rules` / `egress_security_rules` (one block per rule object)
- Route table `route_rules` (one block per route)
- OKE `placement_configs` (one block per availability domain)
- OKE `node_pool_pod_network_option_details` and `node_shape_config` — **also used as a substitute
  for an if/else on whole blocks** (see below)

### Conditional expressions / conditional resources
Two different mechanisms, both used here:

1. **Conditional value**: `condition ? true_val : false_val`
   Example: `prohibit_public_ip_on_vnic = var.is_private` (bool var drives the field directly),
   or `node_pool_size = length(var.availability_domains)`.

2. **Conditional resource/block existence**: instead of an if/else, Terraform uses
   `count` (whole resource) or an empty vs. one-item list fed into `for_each`/`dynamic` (single block).
   - `oci_logging_log.flow_log` uses `count = var.enable_flow_logs ? 1 : 0` — the resource
     doesn't exist in state at all when logging is off.
   - `dynamic "node_shape_config" { for_each = var.node_shape_config != null ? [var.node_shape_config] : [] }`
     — renders the block only for Flex shapes; fixed shapes get nothing (which OCI requires).
   - `dynamic "cluster_pod_network_options"` / `dynamic "node_pool_pod_network_option_details"`
     — only rendered when `var.cni_type == "OCI_VCN_IP_NATIVE"`, so the same module supports
     Flannel overlay clusters too, with zero code changes.

### Making modules reusable/configurable
- No hardcoded compartment IDs, CIDRs, names, or shapes inside `modules/*`.
- Sensible **defaults** only for things that are genuinely optional (e.g. `is_private = true`,
  `enable_flow_logs = false`), never for identifiers.
- Structured `object()`/`list(object())` variables (not loose strings) so the root module passes
  well-typed data and Terraform validates it at plan time.
- A `validation` block on `cni_type` catches typos early instead of failing deep in an API call.
- The subnet module is called **four times** from `environments/dev/main.tf` (endpoint, node,
  pod, LB subnets) with different arguments each time — that's the reusability proof.

---

## 1a. Worker node image resolution (no manual OCID lookup needed)

`modules/oke` resolves the worker node image automatically via the
`oci_containerengine_node_pool_option` data source, scoped to the cluster itself so results
match its exact `kubernetes_version`. It filters for `source_type == "IMAGE"` names matching
`var.node_image_name_regex` (default `^Oracle-Linux-8\.`, which is AMD64 and excludes GPU/Ampere
variants), then picks the lexically-last match — OKE image names embed a date, so that's also
the newest one.

- Using `VM.Standard.E4.Flex` (or any `E*.Flex`/`VM.Standard2.*`/etc.) → keep the default regex (AMD64).
- Using an Ampere shape (`VM.Standard.A1.Flex`, `A2.Flex`) → set `node_image_name_regex` to match
  the aarch64-published images instead.
- Need Oracle Linux 9 instead of 8 → set `node_image_name_regex = "^Oracle-Linux-9\\."`.
- Need to pin an exact image (e.g. a hardened/custom baseline) → set `node_image_id` explicitly;
  it always overrides auto-resolution.

`terraform plan` fails with a clear message (via a `check` block) if no image matches your
regex/Kubernetes version combination, instead of failing deep inside the OKE API call.

## 2. Deploying the infrastructure

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your real OCIDs

terraform init
terraform plan
terraform apply
```

> This config now creates the VCN, Internet Gateway, NAT Gateway, Service Gateway, and the
> Logging log group itself (see `network.tf`) — you don't need to pre-create anything in the
> console except the compartment and your API signing key/auth token.

Fetch kubeconfig (command is also a Terraform output):

```bash
oci ce cluster create-kubeconfig \
  --cluster-id $(terraform output -raw cluster_id) \
  --file $HOME/.kube/config --region <region> --token-version 2.0.0

kubectl get nodes -o wide   # confirm nodes joined and got pod IPs from the pod subnet
```

---

## 3. Lab: deploy app + block volume + Load Balancer

```bash
kubectl apply -f k8s/00-namespace.yaml
kubectl apply -f k8s/01-pvc.yaml
kubectl -n week3-app get pvc app-data-pvc -w   # wait for STATUS=Bound (CSI provisions the OCI block volume)

kubectl apply -f k8s/02-deployment.yaml
kubectl -n week3-app get pods -w

kubectl apply -f k8s/03-service-loadbalancer.yaml
kubectl -n week3-app get svc week3-app-lb -w    # wait for EXTERNAL-IP to populate
```

Once `EXTERNAL-IP` appears, `curl http://<external-ip>/` should hit the app. Check the OCI
Console → Networking → Load Balancers to see the LB Terraform/OKE provisioned automatically in
`lb_subnet`, and Block Storage → Block Volumes to see the volume backing the PVC.

**Building and pushing the app image (Docker/OCIR path — Lab 3/4):**

`app/` contains a small Node.js/Express app (`server.js`), a multi-stage `Dockerfile`, and
`build-and-push.sh` to build + push it to OCIR in one step:

```bash
cd app
REGION=iad \
TENANCY_NAMESPACE=<your-tenancy-object-storage-namespace> \
OCIR_USERNAME='<tenancy-namespace>/<username>' \
OCIR_AUTH_TOKEN='<auth-token>' \
IMAGE_TAG=v1 \
./build-and-push.sh
```

- `REGION` is the short region key in the OCIR hostname (`iad`, `phx`, `fra`, ...), not the
  full region name.
- `TENANCY_NAMESPACE` is your tenancy's Object Storage namespace (Console → Tenancy details).
- `OCIR_AUTH_TOKEN` is generated under Profile → User Settings → Auth Tokens (not your OCI password).

The app exposes:
- `GET /` — returns pod hostname + timestamp (proves the LB is distributing traffic across pods)
- `GET /healthz` — used by the Deployment's readiness/liveness probes
- `GET /data-check` — appends a line to a file on the mounted block volume and returns its
  contents, proving the PVC is writable and persists across pod restarts

Update the `image:` field in `k8s/02-deployment.yaml` with the pushed image reference the
script prints out at the end, and create an image-pull secret if the OCIR repo is private:
```bash
kubectl -n week3-app create secret docker-registry ocirsecret \
  --docker-server=<region>.ocir.io \
  --docker-username='<tenancy-namespace>/<username>' \
  --docker-password='<auth-token>' \
  --docker-email='<your-email>'
```
and reference it with `imagePullSecrets` in the Deployment spec.

---

## 4. KPI checklist mapping

| KPI | Where it's satisfied |
|---|---|
| Terraform Module Quality | `modules/subnet`, `modules/oke` — variablized, dynamic blocks, conditionals, no hardcoding |
| OKE Cluster Deployment Success | `module.oke` in `environments/dev/main.tf`, VCN-native CNI |
| Kubernetes Deployment Success | `k8s/00-03` manifests: namespace, PVC, Deployment, LB Service |
| Infrastructure Readiness | 4 subnets (endpoint/node/pod/LB) + route tables + security lists + flow logs, all module-driven |
| Documentation Quality | this README + inline comments in every `.tf`/`.yaml` file |

## 5. Suggested next steps for your write-up
- Take a screenshot of `terraform apply` output and `kubectl get nodes/pods/svc`.
- Document the target architecture (a simple diagram: IGW/NAT/SGW → 4 subnets → OKE cluster →
  node pool → pods with pod-subnet IPs → LB → internet).
- Note trade-offs: single-AD vs multi-AD placement, RWO block volume limiting replicas to 1,
  flexible LB shape min/max bandwidth chosen.
