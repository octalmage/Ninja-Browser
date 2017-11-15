const electron = require('electron'); // eslint-disable-line import/no-extraneous-dependencies
const childProcess = require('child_process');
const path = require('path');
const url = require('url');

const { app, BrowserWindow, globalShortcut } = electron;

let mainWindow;

function getLargestElement() {
  return new Promise((resolve) => {
    const bin = path.join(__dirname, 'getElement');
    childProcess.execFile(bin, (error, stdout) => {
      const elements = JSON.parse(stdout)
        .filter(element =>
          ![
            '',
            'AXWindow',
            'AXMenu',
            'AXMenuBar',
            'AXMenuBarItem',
          ].includes(element.role));
      let bestElement = null;
      let bestArea = 0;
      for (const element of elements) { // eslint-disable-line no-restricted-syntax
        const newArea = element.height * element.width;
        if (newArea > bestArea) {
          bestElement = element;
          bestArea = newArea;
        }
      }

      return resolve(bestElement);
    });
  });
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    alwaysOnTop: true,
    show: false,
    frame: false,
    transparent: true,
  });

  globalShortcut.register('Command+Alt+B', async () => {
    const bounds = await getLargestElement();
    if (bounds) {
      mainWindow.setContentBounds(bounds, false);
      mainWindow.show();
    }
  });


  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true,
  }));

  mainWindow.on('blur', () => mainWindow.hide());


  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}


app.on('ready', createWindow);


app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});
