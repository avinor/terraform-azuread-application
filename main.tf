terraform {
  required_version = ">= 0.12.0"
  required_providers {
    azuread = ">= 0.5.0"
  }
}

resource "azuread_application" "main" {
  name                       = var.name
  identifier_uris            = var.identifier_uris
  reply_urls                 = var.reply_urls
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = false
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
