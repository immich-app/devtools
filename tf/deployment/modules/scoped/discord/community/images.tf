locals {
  image_paths = fileset(path.module, "images/*.{png,jpg,jpeg,gif,webp,svg}")

  extensions = {
    for path in local.image_paths :
    basename(path) => element(split(".", basename(path)), length(split(".", basename(path))) - 1)
  }

  image_data_uris = {
    for path in local.image_paths :
    basename(path) => format(
      "data:%s;base64,%s",
      lookup({
        "png" : "image/png",
        "jpg" : "image/jpeg",
        "jpeg" : "image/jpeg",
        "gif" : "image/gif",
        "webp" : "image/webp",
        "svg" : "image/svg+xml"
      }, local.extensions[basename(path)], "application/unknown"),
      filebase64(path)
    )
  }
}
