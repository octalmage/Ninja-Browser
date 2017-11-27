const { spawn } = require('child_process');
const path = require('path');
const { Notification } = require('electron'); // eslint-disable-line import/no-extraneous-dependencies

// Fix for https://stackoverflow.com/a/28260423/2233771
module.exports.exec = function exec(command) {
  return new Promise((resolve, reject) => {
    const proc = spawn(command);
    proc.on('error', e => reject(e));

    const list = [];

    proc.stdout.on('data', (chunk) => {
      list.push(chunk);
    });

    proc.stdout.on('end', () => resolve(list.join('')));

    return proc;
  });
};

module.exports.displayNotification = (message) => {
  const notification = new Notification({
    title: 'Ninja Browser',
    body: message,
  });

  notification.show();

  return notification;
};

module.exports.getBinPath = bin =>
  path.join(__dirname.replace('app.asar', 'app.asar.unpacked'), '..', bin);
