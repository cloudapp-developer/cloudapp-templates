const express = require('express');
const bodyParser = require('body-parser');
const { setup, setupSequelize, defineModels } = require('./sequelize');
const logger = require('./logger')

async function main() {
  logger.info('main start');

  const sequelize = setupSequelize();
  const { Todo } = defineModels(sequelize);

  logger.info('mysql setup complete')

  const app = express();
  app.use(bodyParser.json());

  app.use('/api/GetTodoList', async (req, res) => {
    logger.info('/api/GetTodoList')
    const todoList = await Todo.findAll({
      order: [['id', 'DESC']],
    });
    logger.info('/api/GetTodoList response', JSON.stringify(todoList))
    res.send({ todoList });
  });

  app.use('/api/AddTodo', async (req, res) => {
    const {
      APIPayload: { content },
    } = req.body;
    logger.info('AddTodo', req.body, content);
    const todo = await Todo.create({ content });
    res.send({ id: todo.id });
  });

  app.use('/api/RemoveTodo', async (req, res) => {
    const {
      APIPayload: { id },
    } = req.body;
    await Todo.destroy({ where: { id } });
    res.send({ id });
  });

  app.listen(8000, () => {
    logger.info('listening on 8000')
  });
}

if (process.env.SETUP) {
  setup();
} else {
  main();
}