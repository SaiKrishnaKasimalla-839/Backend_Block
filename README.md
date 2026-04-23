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
**terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tf-demo"
    storage_account_name = "tfdemostorage123"
    container_name       = "tfstate"
    key                  = "demo.tfstate"
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-main"
  location = "centralindia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "my-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "my-subnet"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "my-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "my-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "my-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"

  admin_username = "azadmin"
  admin_password = "Az@12345678"
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts"
    version   = "latest"
  }
}**

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
