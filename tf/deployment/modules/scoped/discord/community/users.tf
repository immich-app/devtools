locals {
  users = [
    // Admins
    { username = "alex.tran1502", id = 285511635735543828, role = "admin" },
    { username = "jrasm91", id = 613523742479483183, role = "admin", dev = true },
    { username = "bo0tzz", id = 324007594262003722, role = "admin", dev = true },
    { username = "zackpollard", id = 185097470215192579, role = "admin", dev = true },
    # Team
    { username = "ddietzler", id = 273458650557841408, role = "team", dev = true },
    { username = ".eleman.", id = 1110388960842219662, role = "team" },
    { username = "shenlong", id = 879025674214584330, role = "team", dev = true },
    # Contributors
    { username = "adamantike", id = 820328828580134953, role = "contributor" },
    { username = "hungrypandas", id = 391059578743160832, role = "contributor" },
    { username = "benmccann", id = 709488329003106344, role = "contributor" },
    { username = "bwees", id = 172431702465970176, role = "contributor" },
    { username = "brighteyed", id = 638460185228345345, role = "contributor" },
    { username = "keinfalschparker", id = 1270365817304912046, role = "contributor" },
    { username = "deanfuto_49548", id = 1303064606712922142, role = "contributor" },
    { username = "etnoy", id = 1084581712702472252, role = "contributor" },
    { username = "zody", id = 145524839938129920, role = "contributor" },
    { username = "exonintrendo", id = 281866662007799809, role = "contributor" },
    { username = "jbaez", id = 900373145020678194, role = "contributor" },
    { username = "martabal", id = 261069120416514059, role = "contributor" },
    { username = "matthinc", id = 335669624576278540, role = "contributor" },
    { username = "michelheusschen", id = 234061895865204737, role = "contributor" },
    { username = "starl1ghtshad0w", id = 851188544294092831, role = "contributor" },
    { username = "trustfullama", id = 477906816022609940, role = "contributor" },
    { username = "pixeljonas", id = 160439962502692864, role = "contributor" },
    { username = "samholton", id = 334878799223193611, role = "contributor" },
    { username = "snowknight26", id = 287636133876334613, role = "contributor" },
    { username = "theflamingchicken", id = 720985629323952151, role = "contributor" },
    { username = "uhhthomas", id = 105750004563509248, role = "contributor" },
    { username = "yarossyubayev", id = 519561606175129600, role = "contributor" },
    # Support Crew
    { username = "aviv251", id = 360064066527690753, role = "support" },
    { username = "crushedasian255", id = 386612331288723469, role = "support" },
    { username = "ddshd", id = 271815201290977288, role = "support" },
    { username = "winterharris", id = 330256861980786688, role = "support" },
    { username = "icedragon2002002", id = 303309066246291459, role = "support" },
    { username = "liveofvio", id = 191602681280724992, role = "support" },
    { username = "mraedis", id = 145451920557867008, role = "support" },
    { username = "nicholasflamy", id = 404750535342686209, role = "support" },
    { username = "questionario", id = 573858858221699092, role = "support" },
    { username = "schuhbacca1", id = 275064456210284546, role = "support" },
    { username = "solid256", id = 1142920273851592814, role = "support" },
    { username = "zzzeus.", id = 304729090064252948, role = "support" },
  ]
}

resource "discord_member_roles" "roles" {
  for_each = { for user in local.users : user.id => user if var.env == "prod" || lookup(user, "dev", false) == true }

  server_id = discord_server.server.id
  user_id   = each.value.id

  role {
    role_id  = discord_role.admin.id
    has_role = contains(["admin"], each.value.role)
  }

  role {
    role_id  = discord_role.team.id
    has_role = contains(["team", "admin"], each.value.role)
  }

  role {
    role_id  = discord_role.contributor.id
    has_role = contains(["contributor", "team", "admin"], each.value.role)
  }

  role {
    role_id  = discord_role.support_crew.id
    has_role = contains(["support"], each.value.role)
  }
}
