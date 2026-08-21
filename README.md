# Ejada Cloud Build Internship — Hands-on Tasks & Labs

![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-OCI-red)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Container%20Orchestration-326CE5)
![Oracle Linux](https://img.shields.io/badge/OS-Oracle%20Linux-orange)
![GitHub](https://img.shields.io/badge/Version%20Control-GitHub-black)

## Repository Overview

This repository contains my **hands-on tasks, labs, implementations, and technical documentation** completed during the **Ejada Egypt Summer Internship Program 2026 – Cloud Build Track**.

**Intern:** Mohamed Esam
**Program:** Ejada Egypt Summer Internship Program 2026
**Track:** Cloud Build Track
**Duration:** 4 Weeks

The repository documents the technical work completed throughout the internship, covering **Oracle Cloud Infrastructure (OCI), Terraform, Networking, DevOps, and Kubernetes**.

The work is organized by internship week, with each week containing the assigned tasks and labs, along with their implementation, configuration, architecture, troubleshooting, and verification.

> **Note:** This repository is a collection of internship tasks and labs completed as part of the Ejada Cloud Build Track, rather than a single standalone project.

---

## Tools & Technologies

### Cloud & Infrastructure

* Oracle Cloud Infrastructure (OCI)
* OCI Compute
* OCI Virtual Cloud Network (VCN)
* Oracle Kubernetes Engine (OKE)
* OCI File Storage
* OCI Block Volume
* OCI Load Balancer
* OCI Bastion

### Infrastructure as Code

* Terraform
* Terraform Modules
* Terraform Variables
* Terraform Data Sources
* Terraform Outputs
* Terraform Lifecycle Management
* Terraform Validation

### Networking

* VCN
* Subnets
* Route Tables
* Security Lists
* Internet Gateway
* NAT Gateway
* Service Gateway

### DevOps & Kubernetes

* Kubernetes
* Oracle Kubernetes Engine (OKE)
* kubectl
* OCI CLI
* Managed Kubernetes Worker Nodes
* VCN-Native Pod Networking
* Kubernetes Deployments
* Kubernetes Services
* Kubernetes LoadBalancer

### Development & Version Control

* Git
* GitHub
* Windows PowerShell
* Oracle Linux

---

# Internship Tasks

## Week 1 — OCI Compute & Terraform

The first week focused on the fundamentals of **Oracle Cloud Infrastructure** and **Infrastructure as Code using Terraform**.

### Tasks & Labs

* OCI Compute Deployment
* VCN and Public Subnet
* Internet Gateway
* Route Table
* Security List
* Linux Compute Instance
* Block Volume
* SSH Connectivity
* Terraform Basics
* Infrastructure Lifecycle Management

### Key Concepts

* OCI Compute
* Basic OCI Networking
* Public Cloud Infrastructure
* SSH-based server access
* Terraform configuration
* Infrastructure provisioning
* Terraform Plan and Apply
* Infrastructure destruction and cleanup

---

## Week 2 — OCI Networking & Terraform Intermediate

The second week focused on building a more structured and secure **enterprise-style OCI network** and improving Terraform knowledge.

### Tasks & Labs

* Enterprise Network Deployment
* Public and Private Subnets
* Internet Gateway
* NAT Gateway
* Service Gateway
* Public Route Table
* Private Route Table
* Public Security List
* Private Security List
* OCI File Storage
* File System
* Mount Target
* Bastion and Secure Access Architecture

### Terraform Topics

* Data Sources
* Local Values
* Resource Dependencies
* Lifecycle Rules
* Terraform Formatting
* Terraform Validation
* Remote State Concepts

### Networking Concepts

* CIDR Planning
* Public vs. Private Subnets
* Internet Connectivity
* Private Outbound Connectivity
* OCI Service Access
* Route Management
* Network Security
* Secure Administrative Access

---

## Week 3 — DevOps & Kubernetes

The third week focused on **DevOps, Kubernetes, Terraform Modules, and Oracle Kubernetes Engine (OKE)**.

The infrastructure was redesigned using reusable Terraform modules to improve maintainability and reusability.

### Terraform Modules

The main reusable modules included:

```text
modules/
├── subnet/
└── oke/
```

### Subnet Module

The reusable subnet module was designed to manage:

* Subnet
* Route Table
* Security List
* Logging configuration

The module was designed to be generic and reusable without hardcoded environment-specific values.

### OKE Module

The OKE module was responsible for creating and configuring:

* OKE Cluster
* Managed Worker Node Pool
* Required Kubernetes infrastructure
* VCN-Native Pod Networking

### Kubernetes Tasks

* Oracle Kubernetes Engine (OKE) Cluster
* Managed Worker Node Pool
* VCN-Native Pod Networking
* Kubernetes Application Deployment
* Kubernetes Deployments
* Kubernetes Services
* LoadBalancer Service
* Application Verification
* Infrastructure Troubleshooting

### Troubleshooting

During the OKE deployment, a worker node registration issue occurred where the nodes were created but did not successfully register with the OKE cluster.

The issue was investigated by reviewing the worker node networking and security configuration.

The required Security List rules were updated, followed by another Terraform deployment.

After the changes, the worker nodes successfully registered with the OKE cluster.

This provided practical experience in troubleshooting **cloud networking, security rules, Terraform deployments, and Kubernetes infrastructure**.

---

## Week 4 — Coming Soon

The Week 4 tasks and labs will be added as they are completed during the internship.

This section will be updated with:

* Assigned tasks
* Labs
* Technologies used
* Implementation details
* Architecture
* Troubleshooting
* Verification
* Documentation

---

# Learning Progression

The internship tasks progressively moved from basic cloud infrastructure toward more advanced cloud-native technologies.

```text
OCI Fundamentals
       │
       ▼
Compute Deployment
       │
       ▼
OCI Networking
       │
       ▼
Terraform Infrastructure as Code
       │
       ▼
Enterprise Network Architecture
       │
       ▼
Public / Private Infrastructure
       │
       ▼
Secure Cloud Access
       │
       ▼
Terraform Modules
       │
       ▼
Kubernetes
       │
       ▼
Oracle Kubernetes Engine (OKE)
       │
       ▼
Application Deployment
```

This progression provided hands-on experience with the infrastructure lifecycle, from creating individual cloud resources to managing a Kubernetes-based cloud environment using Infrastructure as Code.

---

# Skills & Knowledge Gained

Through the internship tasks and labs, I gained practical experience in:

* Oracle Cloud Infrastructure
* Cloud Networking
* Infrastructure as Code
* Terraform
* Terraform Modules
* Cloud Security
* Public and Private Network Architecture
* OCI Compute
* OCI Storage
* Kubernetes
* Oracle Kubernetes Engine
* Container Orchestration
* Kubernetes Networking
* Application Deployment
* Infrastructure Troubleshooting
* Cloud Infrastructure Lifecycle Management
* Technical Documentation
* Git and GitHub

---

# Infrastructure Management

The internship also provided practical experience with the complete infrastructure lifecycle:

```text
Design
  ↓
Provision
  ↓
Configure
  ↓
Deploy
  ↓
Verify
  ↓
Troubleshoot
  ↓
Destroy / Cleanup
```

Terraform was used to automate infrastructure provisioning and management, while the OCI Console, OCI CLI, kubectl, and PowerShell were used for configuration, verification, and troubleshooting.

---

# Repository Structure

The repository is organized by internship week:

```text
.
├── Week-1/
│   └── OCI-Compute-Terraform/
│
├── Week-2/
│   └── OCI-Networking/
│
├── Week-3/
│   ├── terraform/
│   │   └── modules/
│   │       ├── subnet/
│   │       └── oke/
│   │
│   └── kubernetes/
│
├── Week-4/
│
├── README.md
└── .gitignore
```

The exact structure may evolve as additional internship tasks are completed.

---

# Documentation

Each internship task is documented with relevant information such as:

* Task objectives
* Architecture
* Configuration
* Terraform implementation
* Deployment steps
* Verification
* Troubleshooting
* Lessons learned
* Cleanup procedures

The documentation is intended to demonstrate both the **implementation process** and the technical concepts learned throughout the internship.

---

# Internship Context

This repository was created as part of my participation in the:

**Ejada Egypt Summer Internship Program 2026 — Cloud Build Track**

The internship provided practical exposure to cloud infrastructure and modern DevOps technologies, with a strong focus on:

* Oracle Cloud Infrastructure
* Terraform
* Cloud Networking
* DevOps
* Kubernetes
* Infrastructure Automation

The tasks progressed from foundational OCI concepts to more advanced infrastructure automation and Kubernetes-based deployments.

---

# Author

**Mohamed Esam**

Computer Science & Artificial Intelligence Student
Faculty of Computers and Artificial Intelligence — Cairo University

**Cloud Build Intern — Ejada Egypt Summer Internship Program 2026**

GitHub: [Mohamedesam122](https://github.com/Mohamedesam122)

LinkedIn: [Mohamed Esam](https://www.linkedin.com/in/mohamed-esam-354638292/)


