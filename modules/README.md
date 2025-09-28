# Terraform Module Documentation

## 📁 File Structure Overview

### 1️⃣ `main.tf` - Core Module Definition

**Purpose:**
- The core of your module that defines resources to create
- Creates Azure resources like AKS clusters, Key Vaults, or Service Principals

**Usage:**
- Terraform reads this file during `terraform apply` to know what resources to create
- Each resource defined here will be deployed according to the variables passed

**Main Components:**
```hcl
# Azure resources
resource "azurerm_resource_group" "main" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  # ... other configurations
}

# Azure AD resources
resource "azuread_application" "app" {
  display_name = var.app_name
}

# Data sources
data "azurerm_client_config" "current" {}

# Modules (if using submodules)
module "service_principal" {
  source = "./modules/service-principal"
  # ... module inputs
}
```

**Naming Conventions:**
- **Resources:** `azurerm_<resource_type>.<name>` (e.g., `azurerm_kubernetes_cluster.aks-cluster`)
- **Modules:** `module.<module_name>` (e.g., `module.service_principal`)

---

### 2️⃣ `variables.tf` - Module Inputs

**Purpose:**
- Declares inputs your module expects
- Ensures reusability by avoiding hardcoded values

**Usage:**
- Terraform reads this before applying to know which values to expect
- Values are provided in:
  - `terraform.tfvars` file
  - Module inputs in `dev/main.tf`
  - Environment variables or CLI arguments

**Example Structure:**
```hcl
variable "cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "West Europe"
}

variable "ssh_public_key" {
  description = "SSH public key for cluster access"
  type        = string
  sensitive   = true
}

variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}
```

**Naming Conventions:**
- Use **snake_case** for variables (`cluster_name`, `keyvault_name`)
- Include descriptive names and descriptions
- Specify types (`string`, `number`, `bool`)
- Use `sensitive = true` for secrets

---

### 3️⃣ `output.tf` - Module Outputs

**Purpose:**
- Declares outputs your module provides to other modules or root configuration
- Useful for sharing IDs, secrets, or connection strings

**Usage:**
- Terraform evaluates outputs after resources are created
- Other modules can reference them via: `module.<module_name>.<output_name>`

**Example Structure:**
```hcl
output "service_principal_object_id" {
  description = "The object ID of the Service Principal for role assignment"
  value       = azuread_service_principal.main.object_id
}

output "keyvault_id" {
  description = "The ID of the created Key Vault"
  value       = azurerm_key_vault.main.id
}

output "client_secret" {
  description = "The client secret of the Service Principal"
  value       = azuread_service_principal_password.main.value
  sensitive   = true
}

output "aks_config" {
  description = "AKS cluster configuration"
  value       = azurerm_kubernetes_cluster.aks-cluster.kube_config
  sensitive   = true
}
```

**Naming Conventions:**
- **snake_case**, descriptive of what is being output
- Include descriptions to clarify usage
- Use `sensitive = true` for confidential data

---

### 4️⃣ How Files Work Together

| File | Purpose | Example Role |
|------|---------|--------------|
| `variables.tf` | Input declaration | `cluster_name`, `ssh_public_key`, `keyvault_name` |
| `main.tf` | Resource creation | Creates AKS cluster, Key Vault, Service Principal |
| `output.tf` | Outputs for other modules | Provides `keyvault_id`, `client_id`, `client_secret` |

**Deployment Flow:**
1. Root `dev/main.tf` calls modules: `service_principal`, `key_vault`, `aks`
2. Variables in `dev/terraform.tfvars` provide personalized values
3. `main.tf` in each module creates the resources in Azure
4. `output.tf` in each module provides IDs/secrets/config to the root module
5. Terraform deploys everything in the correct order

**Example Root Configuration:**
```hcl
module "service_principal" {
  source          = "./modules/service-principal"
  application_name = "dev-ines-app"
}

module "key_vault" {
  source       = "./modules/key-vault"
  keyvault_name = "dev-ines-kv"
  location      = "West Europe"
}

module "aks" {
  source        = "./modules/aks"
  cluster_name  = "dev-ines-cluster"
  location      = "West Europe"
  client_id     = module.service_principal.client_id
  client_secret = module.service_principal.client_secret
}
```

---

### 5️⃣ Naming and Personalization Tips

**Resource Naming:**
```hcl
# Use meaningful, consistent names
resource "azurerm_resource_group" "main" {
  name     = "dev-ines-rg"          # Environment-Name-ResourceType
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "dev-ines-cluster"    # Environment-Name-Cluster
  # ... other config
}

resource "azurerm_key_vault" "main" {
  name                = "dev-ines-kv"         # Environment-Name-KV
  # ... other config
}
```

**Variable Naming:**
- **snake_case**, clear and descriptive
- Examples: `service_principal_name`, `keyvault_name`, `node_pool_name`

**Output Naming:**
- **snake_case**, describe what the output is used for
- Examples: `client_secret`, `keyvault_id`, `cluster_endpoint`

**Module Naming:**
- Use **PascalCase** for module instances
- Examples: `ServicePrincipal`, `KeyVault`, `AKSCluster`

**Best Practices:**
- Use consistent naming patterns across all resources
- Include environment prefixes (dev, staging, prod)
- Use descriptive names that indicate purpose
- Follow Azure naming conventions and limitations