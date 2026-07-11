# AKS deployment with Terraform and GitHub Actions

This repository contains a Terraform plan for deploying a secure Azure Kubernetes Service (AKS) cluster in eastus2 with:

- 2 worker nodes in the default system node pool
- Azure CNI networking
- Azure Policy enabled
- Azure Monitor / Log Analytics integration
- A private-cluster-friendly design

## Prerequisites

Before deploying, create the following GitHub repository secrets:

- AZURE_CLIENT_ID
- AZURE_TENANT_ID
- AZURE_SUBSCRIPTION_ID

You also need to ensure the service principal has permission to create AKS, networking, and monitoring resources in the target subscription.

## Terraform variables

Copy terraform.tfvars.example to terraform.tfvars and adjust values such as:

- node_vm_size: set this to the same SKU used by your IACAzure environment
- node_os_sku: set this to the same image family used by your IACAzure environment
- private_cluster_enabled: set to true for a more secure design or false if you need a public API server

## Remote state backend

This repository uses an Azure Storage backend for Terraform state. Copy `backend.tfvars.example` to `backend.tfvars` and update the values to match your IACAzure storage account and container.

```bash
terraform init -backend-config=backend.tfvars
```

The state file will be stored in the same Azure storage account and container you configure for IACAzure.

## Local validation

```bash
terraform init
terraform plan
##updated environment secret
```

## GitHub Actions

Pushing to the main branch will trigger the workflow and deploy the infrastructure to Azure using the configured GitHub secrets.
