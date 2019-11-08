module "simple" {
    source = "../.."

    name = "simple"
    reply_urls = ["https://simple.example.com"]
    end_date = "2022-01-01T01:02:03Z"
}