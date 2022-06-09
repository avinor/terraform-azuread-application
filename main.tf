terraform {
  required_version = ">= 0.13"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.6.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.99.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azuread_application" "main" {
  display_name               = var.name
  identifier_uris            = var.identifier_uris
  available_to_other_tenants = false
  group_membership_claims    = var.group_membership_claims

  web {
    homepage_url  = var.homepage
    redirect_uris = var.reply_urls
    implicit_grant {
      access_token_issuance_enabled = var.oauth2_allow_implicit_flow
    }
  }


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

  dynamic "app_role" {
    for_each = var.app_roles
    iterator = resource
    content {
      enabled              = true
      allowed_member_types = resource.value.allowed_member_types
      description          = resource.value.description
      display_name         = resource.value.display_name
      value                = resource.value.value
    }
  }
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = false
}

resource "random_password" "unique" {
  length  = 32
  special = false
  upper   = true

  keepers = {
    application = azuread_application.main.id
  }
}

resource "azuread_application_password" "main" {
  application_object_id = azuread_application.main.id
  value                 = random_password.unique.result
  end_date              = var.end_date
}

resource "azurerm_role_assignment" "main" {
  count                = length(var.assignments)
  scope                = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id         = azuread_application.main.object_id
}
