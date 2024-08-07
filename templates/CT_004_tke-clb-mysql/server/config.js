module.exports = {
  mysql: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD.replace(/\\u0026/g, '&'),
    port: +process.env.DB_PORT,
    database: 'cloudapp-todo',
  },
};
