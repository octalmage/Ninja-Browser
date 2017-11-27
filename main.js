const electron = require('electron'); // eslint-disable-line import/no-extraneous-dependencies
const path = require('path');
const url = require('url');
const settings = require('electron-settings');
const pkg = require('./package.json');
const { exec, getBinPath } = require('./src/utilities');
const getLargestElement = require('./src/getLargestElement');

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
let watchMouseTimer;

const isTrusted = getBinPath('isTrusted');

exec(isTrusted, (output) => {
  if (output !== '1') {
    const notification = new Notification({
      title: 'Ninja Browser',
      body: 'Please grant Ninja Browser access to the Mac OS accessibility features, located in System Preferences.',
    });

    notification.show();
  }
});

function getSettings() {
  return {
    mouseGesture: settings.get('mouseGesture', true),
    activationHotkey: settings.get('activationHotkey', true),
    runAtStartup: settings.get('runAtStartup', false),
    escapeHotkey: settings.get('escapeHotkey', false),
    hideOnMouseOut: settings.get('hideOnMouseOut', true),
  };
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
  watchMouseTimer = setInterval(() => {
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

function hideOnEscape(e, input) {
  if (input.key === 'Escape') {
    mainWindow.hide();
  }
}

function processSettings() {
  const {
    mouseGesture,
    activationHotkey,
    runAtStartup,
    escapeHotkey,
  } = getSettings();

  if (mouseGesture) {
    watchMouse();
  } else {
    clearInterval(watchMouseTimer);
  }

  const accelerator = 'Command+Alt+B';

  if (activationHotkey) {
    globalShortcut.register(accelerator, () => {
      showWindow();
    });
  } else if (globalShortcut.isRegistered(accelerator)) {
    globalShortcut.unregister(accelerator);
  }

  if (runAtStartup) {
    app.setLoginItemSettings({ openAtLogin: true });
  } else if (app.getLoginItemSettings().openAtLogin) {
    app.setLoginItemSettings({ openAtLogin: false });
  }

  if (escapeHotkey) {
    mainWindow.webContents.on('before-input-event', hideOnEscape);
  } else {
    mainWindow.webContents.removeListener('before-input-event', hideOnEscape);
  }
}

function createSettingsWindow() {
  const settingsWin = new BrowserWindow({
    toolbar: false,
    width: 350,
    height: 200,
    resizable: false,
    title: 'Settings',
  });

  settingsWin.settings = getSettings();
  settingsWin.updateSettings = (newSettings) => {
    settings.setAll(newSettings);
    settingsWin.close();
    processSettings();
  };

  settingsWin.loadURL(url.format({
    pathname: path.join(__dirname, 'dist/settings.html'),
    protocol: 'file:',
    slashes: true,
  }));
}

function createWindow() {
  appTray = new Tray(path.join(__dirname, 'tray.png'));
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Ninja Browser' },
    { type: 'separator' },
    { label: `v${pkg.version}` },
    { label: 'Settings', click: () => createSettingsWindow() },
    { type: 'separator' },
    { label: 'Exit', click: () => app.exit() },
  ]);

  appTray.setContextMenu(contextMenu);

  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    alwaysOnTop: true,
    show: false,
    frame: false,
    resizable: false,
    hasShadow: false,
    enableLargerThanScreen: true,
  });

  processSettings();

  mainWindow.hideWindow = () => {
    if (getSettings().hideOnMouseOut) {
      mainWindow.hide();
    }
  };

  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true,
  }));

  mainWindow.on('blur', mainWindow.hide);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  app.quit();
});
