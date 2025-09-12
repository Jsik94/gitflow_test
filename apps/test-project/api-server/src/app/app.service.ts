import { Injectable } from '@nestjs/common';

export interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: Date;
}

@Injectable()
export class AppService {
  private todos: Todo[] = [
    {
      id: 1,
      title: '첫 번째 할 일이다',
      completed: false,
      createdAt: new Date(),
    },
    {
      id: 2,
      title: '두 번째 할 일',
      completed: true,
      createdAt: new Date(),
    },
  ];

  private nextId = 3;

  getAllTodos(): Todo[] {
    return this.todos;
  }

  createTodo(title: string): Todo {
    const newTodo: Todo = {
      id: this.nextId++,
      title,
      completed: false,
      createdAt: new Date(),
    };
    this.todos.push(newTodo);
    return newTodo;
  }

  toggleTodo(id: number): Todo | null {
    const todo = this.todos.find((t) => t.id === id);
    if (todo) {
      todo.completed = !todo.completed;
      return todo;
    }
    return null;
  }

  deleteTodo(id: number): boolean {
    const index = this.todos.findIndex((t) => t.id === id);
    if (index !== -1) {
      this.todos.splice(index, 1);
      return true;
    }
    return false;
  }
}
