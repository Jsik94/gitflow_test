import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
} from '@nestjs/common';
import { AppService, Todo } from './app.service';

export class CreateTodoDto {
  title: string;
}

@Controller('todos')
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getAllTodos(): Todo[] {
    return this.appService.getAllTodos();
  }

  @Post()
  createTodo(@Body() createTodoDto: CreateTodoDto): Todo {
    return this.appService.createTodo(createTodoDto.title);
  }

  @Put(':id/toggle')
  toggleTodo(@Param('id') id: string): Todo | null {
    return this.appService.toggleTodo(parseInt(id, 10));
  }

  @Delete(':id')
  deleteTodo(@Param('id') id: string): { success: boolean } {
    const success = this.appService.deleteTodo(parseInt(id, 10));
    return { success };
  }
}
