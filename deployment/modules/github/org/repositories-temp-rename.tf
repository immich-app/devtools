moved {
  from = github_repository.repositories["my.immich.app"]
  to   = github_repository.myimmichapp
}

removed {
  from = github_repository.myimmichapp
}

moved {
  from = github_repository_file.default_files["my.immich.app/.editorconfig"]
  to   = github_repository_file.myimmichappeditor
}

removed {
  from = github_repository_file.myimmichappeditor
}

moved {
  from = github_repository_file.default_files["my.immich.app/LICENSE"]
  to   = github_repository_file.myimmichapplicense
}

removed {
  from = github_repository_file.myimmichapplicense
}

moved {
  from = github_repository_file.default_files["my.immich.app/CODE_OF_CONDUCT.md"]
  to   = github_repository_file.myimmichappcodeofconduct
}

removed {
  from = github_repository_file.myimmichappcodeofconduct
}

moved {
  from = github_repository_file.default_files["my.immich.app/SECURITY.md"]
  to   = github_repository_file.myimmichappsecurity
}

removed {
  from = github_repository_file.myimmichappsecurity
}
