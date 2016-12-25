const WebSocket = require('ws');
const path = require('path');
const fs = require('fs');
const readline = require('readline');
const exec = require('child_process').exec;
const Rcon = require('simple-rcon');

const configuration = require('../config.json');

function die(msg) {
  console.error(msg);
  process.exit(1);
}

function mkfifo(filepath) {
  return new Promise((fulfill, reject) => {
    exec(`mkfifo ${filepath}`, (err, stdout, stderr) => {
      if (err) {
        reject(err);
        return;
      }

      if (stderr) {
        reject(stderr);
        return;
      }

      fulfill(stdout);
    });
  });
}

class FactorioInterface {
  constructor(commandPath) {
    this.commandPath = commandPath;
    this.connections = {};

    this.outputDirectory = path.dirname(commandPath);

    this.rcon = new Rcon({
      host: 'localhost',
      port: configuration.port,
      password: configuration.password,
      timeout: 0
    });
  }

  call(functionName, ...args) {
    const quotedArgs = args.map(arg => `'${arg}'`);
    this.rcon.exec(`/silent-command remote.call('websocket', '${functionName}', ${quotedArgs.join(', ')})`);
  }

  open() {
    if (this.commandStream !== undefined) {
      throw new Error('Already open');
    }

    this.rcon.connect();

    return mkfifo(this.commandPath)
      .then(() => {
        const openStream = () => {
          this.commandStream = readline.createInterface({
            input: fs.createReadStream(this.commandPath, { encoding: 'utf8', autoClose: false }),
          }); 

          this.commandStream.on('line', cmd => {
            this.parseCommand(cmd);
          });

          this.commandStream.on('close', () => openStream());
        };

        openStream();
      });
  }

  parseCommand(cmd) {
    console.log(`Command received: ${cmd}`);

    const [command, ...args] = cmd.split(',');

    switch (command) {
      case 'open': {
        const [connectionId, address] = args;

        console.log(`Opening port with ID ${connectionId} to ${address}`);

        if (connectionId in this.connections) {
          console.error('Connection ID already registered');
          return;
        }

        const socket = new WebSocket(address);
        socket.on('message', data => this.call('_rx', connectionId, data));

        const fifoPath = path.join(this.outputDirectory, 'tx', `${connectionId}.pipe`);

        const openStream = () => {
          const fifoStream = readline.createInterface({
            input: fs.createReadStream(fifoPath, { encoding: 'utf8', autoClose: false }),
          }); 

          fifoStream.on('close', () => openStream());
          fifoStream.on('line', data => socket.send(data));
        };

        if (!fs.existsSync(path.dirname(fifoPath))) {
          fs.mkdirSync(path.dirname(fifoPath));
        }

        mkfifo(fifoPath).then(() => openStream());

        this.connections[connectionId] = {
          socket,
          fifoPath,
        }

        break;
      }
      default:
        console.log(`Unrecognized command: ${cmd}`);
    }
  }
}

function main() {
  const [commandPipePath] = process.argv.slice(2);

  if (commandPipePath === undefined) {
    die(`usage: <command pipe path>`);
  }

  const interface = new FactorioInterface(commandPipePath);
  interface.open();
}

main();
