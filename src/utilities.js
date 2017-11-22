const { spawn } = require('child_process');
const path = require('path');

// Fix for https://stackoverflow.com/a/28260423/2233771
module.exports.exec = function exec(command) {
  return new Promise((resolve) => {
    const proc = spawn(command);

    const list = [];

    proc.stdout.on('data', (chunk) => {
      list.push(chunk);
    });

    proc.stdout.on('end', () => {
      resolve(list.join(''));
    });
  });
};

module.exports.getBinPath = bin =>
  path.join(__dirname.replace('app.asar', 'app.asar.unpacked'), '..', bin);
