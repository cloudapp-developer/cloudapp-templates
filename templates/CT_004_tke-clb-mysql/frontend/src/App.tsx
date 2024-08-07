import 'tea-component/dist/tea.css';

import React, { useEffect, useState } from 'react';
import {
  Card,
  EmptyTip,
  Input,
  LoadingTip,
  Table,
  message,
  ConfigProvider,
} from 'tea-component';
import { callAPI } from './runtime';

const { selectable } = Table.addons;

interface Todo {
  id: string;
  content: string;
}

export default function App() {
  const [ready, setReady] = useState(false);
  const [todoList, setTodoList] = useState<Todo[]>([]);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const [inputValue, setInputValue] = useState<string>('');

  useEffect(() => {
    getTodoList();
  }, []);

  async function getTodoList() {
    const {
      ResponseBody: { todoList },
    } = await callAPI<{ todoList: Todo[] }>('GetTodoList');
    setTodoList(todoList);
    setReady(true);
  }

  async function addTodo(content: string) {
    const { hide } = message.loading({ content: '创建事项中' });
    await callAPI('AddTodo', { content });
    await getTodoList();
    hide();
  }

  async function removeTodo(id: string) {
    const { hide } = message.loading({ content: '移除事项中' });
    await callAPI('RemoveTodo', { id });
    await getTodoList();
    setSelectedId(null);
    hide();
  }

  return (
    <ConfigProvider classPrefix="cloudapp">
      <Card style={{ maxWidth: 520 }}>
        <Card.Body title="待办事项" subtitle={ready && String(todoList.length)}>
          <Input
            placeholder="写下你的待办事项"
            size="full"
            value={inputValue}
            onChange={(value) => setInputValue(value)}
            onPressEnter={(value) => {
              addTodo(value);
              setInputValue('');
            }}
          />
          <Table
            records={todoList}
            recordKey="id"
            hideHeader
            topTip={
              !ready ? (
                <LoadingTip />
              ) : !todoList.length ? (
                <EmptyTip emptyText="暂无待办事项" />
              ) : null
            }
            columns={[
              {
                key: 'content',
                header: '内容',
              },
            ]}
            addons={[
              selectable({
                rowSelect: true,
                value: selectedId ? [selectedId] : [],
                onChange: (id) => {
                  if (id[0]) {
                    setSelectedId(id[0]);
                    removeTodo(id[0]);
                  }
                },
              }),
            ]}
          />
        </Card.Body>
      </Card>
    </ConfigProvider>
  );
}
