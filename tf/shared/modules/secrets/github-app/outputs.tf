output "original_pem_secrets" {
  description = "Original secrets with PEM format certificates"
  value = {
    for key, item in onepassword_item.manual : key => {
      id    = item.id
      title = item.title
    }
  }
  sensitive = true
}

output "certificates" {
  description = "Certificate details (only for items with changed PEM values)"
  value = {
    for key, item in onepassword_item.converted : key => {
      pkcs1           = item.section[0].field[0].value
      pkcs8           = item.section[0].field[1].value
      app_id          = item.section[0].field[2].value
      installation_id = item.section[0].field[3].value
      owner           = item.section[0].field[4].value
    }
  }
  sensitive = true
}
