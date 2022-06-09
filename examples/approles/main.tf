module "approles" {
  source = "../.."

  name          = "approles"
  redirect_uris = ["https://simple.example.com/"]
  end_date      = "2022-01-01T01:02:03Z"

  required_resource_access = []

  app_roles = [
    {
      allowed_member_types = ["User"]
      description          = "Application Admin Users"
      display_name         = "Application Admin"
      value                = "Admin"
    },
    {
      allowed_member_types = ["User"]
      description          = "Application Read Users"
      display_name         = "Application Read"
      value                = "Read"
    },
  ]
}
