import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { PreviewCreateDto, PreviewDto } from 'src/dtos/preview.dto';
import { PreviewService } from 'src/services/preview.service';

@Controller('preview')
export class PreviewController {
  constructor(private service: PreviewService) {}

  @Get()
  getPreviewInstances(): Promise<Array<PreviewDto>> {
    return this.service.getPreviewInstances();
  }

  @Get(':name')
  getPreviewInstance(@Param() name: string): Promise<PreviewDto> {
    return this.service.getPreviewInstance(name);
  }

  @Post()
  createPreviewInstance(@Body() dto: PreviewCreateDto): Promise<PreviewDto> {
    return this.service.createPreviewInstance(dto);
  }
}
