const electron = require('electron'); // eslint-disable-line import/no-extraneous-dependencies
const { spawn } = require('child_process');
const path = require('path');
const url = require('url');

const {
  app,
  BrowserWindow,
  globalShortcut,
  Tray,
  Menu,
  Notification,
} = electron;
app.dock.hide();

let mainWindow;
let appTray = null;

/**
 * Handle asar packages:
 * https://electron.atom.io/docs/tutorial/application-packaging/#executing-binaries-inside-asar-archive
 */
const getBinPath = bin => path.join(__dirname.replace('app.asar', 'app.asar.unpacked'), bin);

const getElements = getBinPath('getElements');
const isTrusted = getBinPath('isTrusted');

// Fix for https://stackoverflow.com/a/28260423/2233771
function exec(command, callback) {
  const proc = spawn(command);

  const list = [];

  proc.stdout.on('data', (chunk) => {
    list.push(chunk);
  });

  proc.stdout.on('end', () => {
    callback(list.join(''));
  });
}

exec(isTrusted, (output) => {
  if (output !== '1') {
    const notification = new Notification({
      title: 'Ninja Browser',
      body: 'Please grant Ninja Browser access to the Mac OS accessibility features, located in System Preferences.',
    });

    notification.show();
  }
});

function getLargestElement() {
  return new Promise((resolve) => {
    exec(getElements, (stdout) => {
      // TODO: Catch parse errors.
      const elements = JSON.parse(stdout);
      let bestElement = null;
      let bestArea = 0;
      const elementsLength = elements.length;
      for (let i = 0; i < elementsLength; i += 1) {
        const element = elements[i];
        if (![
          '',
          'AXWindow', // Exclude windows, use these as a last resort.
          'AXMenu', // Menus aren't a great choice.
          'AXMenuBar', // This is the menu bar at the top, also not good.
          'AXMenuBarItem', // Related to above.
          'AXSplitGroup', // This means that it has children, and they might be better picks.
        ].includes(element.role)) {
          const newArea = element.height * element.width;
          if (newArea > bestArea) {
            bestElement = element;
            bestArea = newArea;
          }
        }
      }

      /**
       *  TODO: Look for AXCloseButton subRole and use that to help fix windows
       *  that have custom menu bars.
       */
      // TODO: Make sure bestElement doesn't match window size, if it does shrink it.

      // Check to make sure the element is large enough.
      if (!bestElement || bestElement.width < 100 || bestElement.height < 100) {
        ([bestElement] = elements.filter(element => ['AXWindow', 'AXStandardWindow'].includes(element.role)));
        // Account for menu bar.
        bestElement.y += 20;
        bestElement.height -= 20;
      }

      return resolve(bestElement);
    });
  });
}

async function showWindow() {
  const bounds = await getLargestElement();
  if (bounds) {
    mainWindow.setContentBounds(bounds, false);
    mainWindow.show();
  }
}

function watchMouse() {
  const { screen } = electron;
  let cursor = screen.getCursorScreenPoint();
  let display;
  let hits = '';
  let wait = false;
  let expire = Date.now();
  setInterval(() => {
    if (expire < Date.now()) {
      hits = '';
    }

    cursor = screen.getCursorScreenPoint();
    display = screen.getDisplayNearestPoint(cursor);
    if (cursor.x < 50) {
      expire = Date.now() + 2000;
      if (!wait) {
        wait = true;
        hits = `1${hits}`;
      }
    } else if (cursor.x > (display.bounds.width - 50)) {
      expire = Date.now() + 2000;
      if (!wait) {
        wait = true;
        hits = `2${hits}`;
      }
    } else {
      wait = false;
    }

    hits = hits.substring(0, 3);
    if (hits === '121' || hits === '212') {
      showWindow();
      hits = '';
    }
  }, 100);
}

function createWindow() {
  appTray = new Tray(path.join(__dirname, 'tray.png'));
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Ninja Browser' },
    { type: 'separator' },
    { label: 'Exit', click: () => app.exit() },
  ]);

  appTray.setContextMenu(contextMenu);

  watchMouse();

  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    alwaysOnTop: true,
    show: false,
    frame: false,
    resizable: false,
    hasShadow: false,
  });

  globalShortcut.register('Command+Alt+B', async () => {
    showWindow();
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
  app.quit();
});
