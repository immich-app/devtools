import { Injectable } from '@nestjs/common';
import { PreviewCreateDto, PreviewDto } from 'src/dtos/preview.dto';

@Injectable()
export class PreviewService {
  private apiUrl = 'http://localhost:60343/api';
  async getPreviewInstances(): Promise<Array<PreviewDto>> {
    // const result = await fetch(`${this.apiUrl}/preview`)

    // return result.json()
    return [
      { name: 'foo', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
      { name: 'foo2', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
      { name: 'foo3', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
      { name: 'foo4', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
      { name: 'foo5', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
      { name: 'foo6', spec: { database: {}, immich: { server: {}, tag: 'tag' } }, status: 'idk' },
    ];
  }

  async getPreviewInstance(name: string): Promise<PreviewDto> {
    const result = await fetch(`${this.apiUrl}/${name}`);

    return result.json();
  }

  async createPreviewInstance(dto: PreviewCreateDto): Promise<PreviewDto> {
    return {} as any;
  }
}
