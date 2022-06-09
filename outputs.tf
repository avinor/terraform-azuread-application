output "object_id" {
  description = "The object id of application. Can be used to assign roles to user."
  value       = azuread_application.main.object_id
}

output "client_id" {
  description = "The application id of AzureAD application created."
  value       = azuread_application.main.application_id
}

output "client_secret" {
  description = "Password for service principal."
  value       = azuread_application_password.main.value
  sensitive   = true
}
