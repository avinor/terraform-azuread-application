variables {
  name                     = "simple"
  redirect_uris            = ["https://simple.example.com/"]
  end_date                 = "2022-01-01T01:02:03Z"
  required_resource_access = []

}
run "simple" {
  command = plan
}