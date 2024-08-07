const dayjs = require('dayjs')

module.exports = {
  info: function(message) {
    console.log(`${dayjs().format()} ${message}`)
  }
}