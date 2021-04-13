terraform {
  required_version = ">= 0.13"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 0.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 1.44.0"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

resource "azuread_application" "main" {
  name                       = var.name
  homepage                   = var.homepage
  identifier_uris            = var.identifier_uris
  reply_urls                 = var.reply_urls
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = var.oauth2_allow_implicit_flow
  type                       = var.type
  group_membership_claims    = var.group_membership_claims

  dynamic "required_resource_access" {
    for_each = var.required_resource_access
    iterator = resource
    content {
      resource_app_id = resource.value.resource_app_id

      dynamic "resource_access" {
        for_each = resource.value.resource_access
        iterator = access
        content {
          id   = access.value.id
          type = access.value.type
        }
      }
    }
  }
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = false
}

resource "random_string" "unique" {
  length  = 32
  special = false
  upper   = true

  keepers = {
    application = azuread_application.main.id
  }
}

resource "azuread_application_password" "main" {
  application_object_id = azuread_application.main.id
  value                 = random_string.unique.result
  end_date              = var.end_date
}

resource "azurerm_role_assignment" "main" {
  count                = length(var.assignments)
  scope                = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id         = azuread_application.main.object_id
}
