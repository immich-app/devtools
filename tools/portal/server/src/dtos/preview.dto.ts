export class PreviewDto {
  name!: string;
  spec!: PreviewSpecDto;
  status!: any;
}

export class PreviewCreateDto {
  name!: string;
  spec!: PreviewSpecDto;
}

class PreviewStatusDto {
  conditions!: any[]
}

class PreviewSpecDto {
  immich!: ImmichConfigurationDto;
  database!: DatabaseConfigurationDto;
}

class ImmichConfigurationDto {
    tag!: string;
    server!: ImmichServerConfigurationDto
}

class ImmichServerConfigurationDto {
  replicas?: number
}

class DatabaseConfigurationDto {
  initType?: string
}
