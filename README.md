# Backend_Block

🧠 Terraform Backend — Complete Study Flow
📌 1. What is Backend?

In Terraform:

👉 Backend = where Terraform stores its state file (.tfstate)

🎯 2. Why Backend?

👉 Without backend:

State in local machine ❌
Not shareable ❌
Risky ❌

👉 With backend:

Stored in cloud ✅
Team usage ✅
Locking ✅
☁️ 3. Azure Backend Service

We use:

👉 Azure Blob Storage

🧩 4. Architecture (Remember This)
Storage Account
   ↓
Container (tfstate)
   ↓
File (demo.tfstate)
🚀 5. Complete Flow (Step-by-Step)
🟢 Step 1: Create Backend Storage

📁 Folder: backend-setup

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tf-demo"
  location = "centralindia"
}

resource "azurerm_storage_account" "st" {
  name                     = "tfdemostorage123"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.st.name
  container_access_type = "private"
}
▶️ Run:
terraform init
terraform apply
🟢 Step 2: Create Main Project

📁 Folder: main-project

🔹 Backend Block
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-demo"
    storage_account_name = "tfdemostorage123"
    container_name       = "tfstate"
    key                  = "demo.tfstate"
  }
}
🔹 Provider
provider "azurerm" {
  features {}
}
🔹 Infrastructure (Example VM)
resource "azurerm_resource_group" "rg" {
  name     = "rg-main"
  location = "centralindia"
}

👉 Add your VM, VNet, NIC, etc.

▶️ Run:
terraform init
terraform apply
🔥 6. What Happens Internally?
During terraform init
Reads backend block
Connects to Azure
Creates/reads state file
During terraform apply
Creates resources
Stores all details in .tfstate
📦 7. What is Stored in State File?

👉 Everything:

VM details
Network info
Resource IDs
Config values
👨‍💻 8. Team Usage Flow

Your friend:

git clone repo
az login
terraform init
terraform apply

👉 Gets same state → works on same infra

🔐 9. Locking Concept

👉 Only one user can run:

terraform apply

👉 Prevents conflicts

⚠️ 10. Important Rules

❌ Backend cannot use:

resources
outputs
variables directly

❌ Don’t create backend + use backend in same project

✅ Always:

Create backend first
Then use it
🧠 11. Final Mental Model
Step 1 → Create storage (empty box)

Step 2 → Connect Terraform to box (backend)

Step 3 → Create resources

Step 4 → Store state inside box
💬 12. One-Line Summary

👉
“Terraform backend stores the state file remotely so multiple users can safely manage infrastructure.”
