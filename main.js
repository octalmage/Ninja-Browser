const electron = require('electron'); // eslint-disable-line import/no-extraneous-dependencies
const childProcess = require('child_process');
const path = require('path');
const url = require('url');

const { app, BrowserWindow, globalShortcut } = electron;
app.dock.hide();

let mainWindow;

function getLargestElement() {
  return new Promise((resolve) => {
    const bin = path.join(__dirname, 'getElement');
    childProcess.execFile(bin, (error, stdout) => {
      const parsed = JSON.parse(stdout);
      const elements = parsed
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

      // TODO: Make sure bestElement doesn't match window size, if it does shrink it.
      // Check to make sure the element is large enough.
      if (bestElement.width < 100 && bestElement.height < 100) {
        ([bestElement] = parsed.filter(element => ['AXWindow', 'AXStandardWindow'].includes(element.role)));
        // Account for menu bar.
        bestElement.y += 20;
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
    resizable: false,
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
