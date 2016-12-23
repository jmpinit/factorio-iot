const Rcon = require('simple-rcon');

const configuration = require('../config.json');

console.log(`Connecting to port ${configuration.port} with password "${configuration.password}"`);

const client = new Rcon({
  host: 'localhost',
  port: configuration.port,
  password: configuration.password,
  timeout: 0
});

client.on('authenticated', () => console.log('authenticated'))
client.on('connected', () => console.log('connected'));
client.on('disconnected', () => console.log('disconnected'));

client.connect();

const name = 'Bob';

setInterval(() => {
  client.exec(`/silent-command remote.call('iot', 'sayHello', '${name}')`);
  console.log(`said hello to ${name}`);
}, 3000);
