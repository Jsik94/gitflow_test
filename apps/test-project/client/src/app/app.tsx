import { useState, useEffect } from 'react';
import styles from './app.module.css';

interface Todo {
  id: number;
  title: string;
  completed: boolean;
  createdAt: string;
}

const API_BASE_URL = 'http://localhost:3000/api';

export function App() {
  const [todos, setTodos] = useState<Todo[]>([]);
  const [newTodoTitle, setNewTodoTitle] = useState('');
  const [loading, setLoading] = useState(false);

  // 모든 Todo 가져오기
  const fetchTodos = async () => {
    try {
      setLoading(true);
      const response = await fetch(`${API_BASE_URL}/todos`);
      const data = await response.json();
      setTodos(data);
    } catch (error) {
      console.error('Todo 목록을 가져오는데 실패했습니다:', error);
    } finally {
      setLoading(false);
    }
  };

  // 새 Todo 추가
  const addTodo = async () => {
    if (!newTodoTitle.trim()) return;

    try {
      const response = await fetch(`${API_BASE_URL}/todos`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ title: newTodoTitle }),
      });
      const newTodo = await response.json();
      setTodos([...todos, newTodo]);
      setNewTodoTitle('');
    } catch (error) {
      console.error('Todo 추가에 실패했습니다:', error);
    }
  };

  // Todo 완료 상태 토글
  const toggleTodo = async (id: number) => {
    try {
      await fetch(`${API_BASE_URL}/todos/${id}/toggle`, {
        method: 'PUT',
      });
      fetchTodos(); // 목록 새로고침
    } catch (error) {
      console.error('Todo 상태 변경에 실패했습니다:', error);
    }
  };

  // Todo 삭제
  const deleteTodo = async (id: number) => {
    try {
      await fetch(`${API_BASE_URL}/todos/${id}`, {
        method: 'DELETE',
      });
      setTodos(todos.filter((todo) => todo.id !== id));
    } catch (error) {
      console.error('Todo 삭제에 실패했습니다:', error);
    }
  };

  useEffect(() => {
    fetchTodos();
  }, []);

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <h1>📝 Todo 애플리케이션</h1>
        <p>간단한 할 일 관리 앱입니다</p>
      </header>

      <main className={styles.main}>
        <div className={styles.addTodo}>
          <input
            type="text"
            value={newTodoTitle}
            onChange={(e) => setNewTodoTitle(e.target.value)}
            placeholder="새로운 할 일을 입력하세요..."
            className={styles.input}
            onKeyPress={(e) => e.key === 'Enter' && addTodo()}
          />
          <button onClick={addTodo} className={styles.addButton}>
            추가
          </button>
        </div>

        {loading ? (
          <div className={styles.loading}>로딩 중...</div>
        ) : (
          <div className={styles.todoList}>
            {todos.length === 0 ? (
              <div className={styles.emptyState}>
                할 일이 없습니다. 새로운 할 일을 추가해보세요!
              </div>
            ) : (
              todos.map((todo) => (
                <div
                  key={todo.id}
                  className={`${styles.todoItem} ${
                    todo.completed ? styles.completed : ''
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={todo.completed}
                    onChange={() => toggleTodo(todo.id)}
                    className={styles.checkbox}
                  />
                  <span className={styles.todoTitle}>{todo.title}</span>
                  <button
                    onClick={() => deleteTodo(todo.id)}
                    className={styles.deleteButton}
                  >
                    삭제
                  </button>
                </div>
              ))
            )}
          </div>
        )}

        <div className={styles.stats}>
          <p>
            전체: {todos.length} | 완료:{' '}
            {todos.filter((t) => t.completed).length} | 미완료:{' '}
            {todos.filter((t) => !t.completed).length}
          </p>
        </div>
      </main>
    </div>
  );
}

export default App;
