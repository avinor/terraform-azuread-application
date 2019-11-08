# AzureAD Application

A general module to create an Azure AD application and optionally assign it roles. It will create a service principal associated with the application and create a password for application.

## Requirements

- Requires access to Azure AD to create application.
- **Owner** required when assigning roles using *assignments* variable

## Usage

Example using [tau](https://github.com/avinor/tau) for deployment

```terraform
module {
    source = "avinor/application/azuread"
    version = "1.0.0"
}

inputs {
    name = "simple"
}
```

Assigning roles for application:

```terraform
module {
    source = "avinor/application/azuread"
    version = "1.0.0"
}

inputs {
    name = "simple"
    reply_urls = ["https://simple.example.com"]
    end_date = "2022-01-01T01:02:03Z"

    assignments = [
        {
            scope = "/subscriptions/xxxx"
            role_definition_name = "Contributor"
        }
    ]
}
```

## Assignments

Usign the `assignments` variable it can assign role access to various resources. This will require Owner access to those subscriptions / resources though.
