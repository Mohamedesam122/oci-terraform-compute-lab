# OCI & Terraform Compute Deployment

![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-OCI-red)
![Terraform](https://img.shields.io/badge/Terraform-IaC-7B42BC)
![Linux](https://img.shields.io/badge/OS-Oracle%20Linux-orange)
![GitHub](https://img.shields.io/badge/Version%20Control-GitHub-black)

Hands-on Oracle Cloud Infrastructure (OCI) and Terraform project focused on deploying and managing cloud infrastructure using Infrastructure as Code (IaC).

This project was completed as part of the **Ejada Egypt Summer Internship Program 2026 – Cloud Build Track**.

---

## Project Overview

The objective of this project is to gain practical experience with Oracle Cloud Infrastructure and Terraform by building a basic OCI environment and deploying a Linux Compute Instance.

The project covers:

- OCI Virtual Cloud Network (VCN)
- Public Subnet
- Internet Gateway
- Route Table
- Security List
- Linux Compute Instance
- Block Volume
- SSH connectivity
- Terraform Infrastructure as Code
- Infrastructure lifecycle management
- Cloud resource cleanup

The networking environment can be created through the OCI Console, while Terraform is used to automate infrastructure deployment according to the internship requirements.

---

# Architecture

The environment is designed around an OCI Virtual Cloud Network containing a public subnet and a Linux Compute Instance.

```text
                         INTERNET
                             |
                             |
                    +----------------+
                    | Internet       |
                    | Gateway        |
                    +-------+--------+
                            |
                            v
                    +---------------+
                    | Route Table   |
                    | 0.0.0.0/0      |
                    +-------+-------+
                            |
                            v
        +------------------------------------------+
        |                OCI VCN                   |
        |              10.0.0.0/16                 |
        |                                          |
        |        +-------------------------+       |
        |        |     Public Subnet       |       |
        |        |      10.0.0.0/24        |       |
        |        |                         |       |
        |        |   +-----------------+   |       |
        |        |   | Compute Instance|   |       |
        |        |   |   Oracle Linux  |   |       |
        |        |   +--------+--------+   |       |
        |        |            |            |       |
        |        |            v            |       |
        |        |      +-----------+      |       |
        |        |      |   Block   |      |       |
        |        |      |  Volume   |      |       |
        |        |      +-----------+      |       |
        |        +-------------------------+       |
        |                                          |
        +------------------------------------------+
