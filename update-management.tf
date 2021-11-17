terraform {

  required_version = ">=0.12"
  
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }
}

provider "azurerm" {
  features {}
}
locals {

  location = "west europe"

  automation_account_location = "west europe"

#To Enable Update-Management
}
resource "null_resource" "example2" {
  provisioner "local-exec" {
    command= <<EOT
    $sched = New-AzAutomationSchedule -ResourceGroupName tf-example-rg -AutomationAccountName tf-example-automation-account -Name myupdateconfig -Description test-OneTime -OneTime -StartTime $startTime -ForUpdateConfiguration
    New-AzAutomationSoftwareUpdateConfiguration -AutomationAccountName tf-example-automation-account -Linux -ResourceGroupName tf-example-rg -Schedule $sched -AzureVMResourceId /subscriptions/86a69c6a-d078-4573-9aff-75d75cd853b8/resourceGroups/tf-example-rg/providers/Microsoft.Compute/virtualMachines/ds-test -Duration (New-TimeSpan -Hours 2) -IncludedPackageClassification critical
    EOT
    interpreter = ["PowerShell", "-Command"]
    
  }
}


# Create Resource Group

resource "azurerm_resource_group" "rg" {

  name     = "tf-example-rg"

  location = local.location

}

# Create a Automation Account

resource "azurerm_automation_account" "automation_account" {

  name                = "tf-example-automation-account"

  location            = local.automation_account_location

  resource_group_name = azurerm_resource_group.rg.name

  sku_name = "Basic"

}

# Create a Log Analytics Workspace

resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {

  name                = "tf-example-log-analytics-workspace"

  location            = azurerm_resource_group.rg.location

  resource_group_name = azurerm_resource_group.rg.name

  sku                 = "PerGB2018"

  retention_in_days   = 30

}

# Link Log Analytics Workspace to Automation Account

resource "azurerm_log_analytics_linked_service" "autoacc_linked_log_workspace" {

  resource_group_name = azurerm_resource_group.rg.name

  workspace_name      = azurerm_log_analytics_workspace.log_analytics_workspace.name

  resource_id         = azurerm_automation_account.automation_account.id

}

# Enable Update Management solution

resource "azurerm_log_analytics_solution" "update_solution" {

  depends_on = [

    azurerm_log_analytics_linked_service.autoacc_linked_log_workspace

  ]

  solution_name         = "Updates"

  location              = azurerm_resource_group.rg.location

  resource_group_name   = azurerm_resource_group.rg.name

  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id

  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {

    publisher = "Microsoft"

    product   = "OMSGallery/Updates"

  }

}
