import { Module } from '@nestjs/common';
import { PreviewController } from 'src/controllers/preview.controller';
import { PreviewService } from 'src/services/preview.service';

@Module({
  imports: [],
  controllers: [PreviewController],
  providers: [PreviewService],
})
export class AppModule {}
