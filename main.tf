terraform {
  required_version = ">= 0.13"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.22.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.9.0"
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

resource "random_uuid" "app_roles_id" {
  for_each = { for r in var.app_roles : r.value => r }
}

resource "azuread_application" "main" {
  display_name            = var.name
  identifier_uris         = var.identifier_uris
  sign_in_audience        = "AzureADMyOrg"
  group_membership_claims = var.group_membership_claims

  web {
    homepage_url  = var.homepage
    redirect_uris = var.redirect_uris

    implicit_grant {
      access_token_issuance_enabled = var.access_token_issuance_enabled
      id_token_issuance_enabled     = var.id_token_issuance_enabled
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
      id                   = random_uuid.app_roles_id[resource.value.value].result
    }
  }
}

resource "azuread_service_principal" "main" {
  application_id               = azuread_application.main.application_id
  app_role_assignment_required = false
}

resource "azuread_application_password" "main" {
  application_object_id = azuread_application.main.id
  end_date              = var.end_date
}

resource "azurerm_role_assignment" "main" {
  count                = length(var.assignments)
  scope                = var.assignments[count.index].scope
  role_definition_name = var.assignments[count.index].role_definition_name
  principal_id         = azuread_application.main.object_id
}
