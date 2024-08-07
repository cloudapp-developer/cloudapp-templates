const { Sequelize, DataTypes } = require('sequelize');
const mysql = require('mysql2/promise');
const config = require('./config');

const { database, host, port, user, password } = config.mysql;

async function setup() {
  console.log('connect to mysql', {
    host,
    port,
    user,
    password
  })

  try {
    const connection = await mysql.createConnection({
      host,
      port,
      user,
      password,
    });
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${database}\`;`);

    const sequelize = setupSequelize();
    defineModels(sequelize);
    await sequelize.sync();
    process.exit(0);
  } catch (err) {
    console.error('setup error', err.message)
  }
}

function setupSequelize() {
  console.log('setup mysql', {
    host,
    port,
    user,
    password
  })

  const sequelize = new Sequelize({
    host,
    port,
    username: user,
    password,
    database,
    dialect: 'mysql',
    define: {
      paranoid: true,
      timestamps: true,
      charset: 'utf8mb4',
      collate: 'utf8mb4_unicode_520_ci',
      freezeTableName: true,
    },
  });

  return sequelize;
}

function defineModels(sequelize) {
  const Todo = sequelize.define('Todo', {
    id: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    content: DataTypes.TEXT,
  });
  return { Todo };
}

module.exports = { setup, setupSequelize, defineModels };
