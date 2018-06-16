const electron = require('electron'); // eslint-disable-line import/no-extraneous-dependencies
const path = require('path');
const url = require('url');
const pkg = require('./package.json');
const { getSettings, defaultSettings, saveSettings } = require('./src/settings');
const { exec, getBinPath, displayNotification } = require('./src/utilities');
const getLargestElement = require('./src/getLargestElement');
const EventEmitter = require('events');

const {
  app,
  BrowserWindow,
  globalShortcut,
  Tray,
  Menu,
} = electron;

const browserEvents = new EventEmitter();

app.dock.hide();

let mainWindow;
let settingsWin;
let appTray = null;
let watchMouseTimer;

const isTrusted = getBinPath('dist/isTrusted');

exec(isTrusted).then((output) => {
  if (output !== '1') {
    displayNotification('Please grant Ninja Browser access to the Mac OS accessibility features, located in System Preferences.');
  }
});

function hideWindow() {
  mainWindow.hide();
  // This is needed to activate the next window.
  if (typeof app.hide === 'function') {
    app.hide();
  }
}

function settingsWinShowing() {
  return settingsWin && !settingsWin.isDestroyed();
}

async function showWindow() {
  let bounds;
  try {
    bounds = await getLargestElement();
  } catch (e) {
    if (e.code === 'ENOENT') {
      displayNotification('Error launching native code.');
    } else {
      displayNotification(e.toString());
    }
  }

  if (settingsWinShowing()) {
    settingsWin.destroy();
  }

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
    hideWindow();
  }
}

function processSettings() {
  const {
    mouseGesture,
    activationHotkey,
    runAtStartup,
    escapeHotkey,
    grayScaleWebpage,
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

  mainWindow.grayScaleWebpage = grayScaleWebpage;
  browserEvents.emit('sync');
}

function createSettingsWindow() {
  // If the settings window is already open, just show it.
  if (settingsWinShowing()) {
    settingsWin.show();
    return;
  }

  // Hide the browser window before showing the settings dialog, since hideWindow
  // calls hide.app().
  mainWindow.blur();

  settingsWin = new BrowserWindow({
    toolbar: false,
    width: 350,
    height: 275,
    resizable: false,
    title: 'Settings',
  });

  // Since hiding the mainWindow runs app.hide, we need to run app.show().
  setImmediate(() => app.show());

  settingsWin.settings = getSettings();
  settingsWin.settingsLabels = defaultSettings;
  settingsWin.updateSettings = (newSettings) => {
    saveSettings(newSettings);
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
      hideWindow();
    }
  };

  mainWindow.grayScaleWebpage = getSettings().grayScaleWebpage;
  mainWindow.events = browserEvents;

  mainWindow.loadURL(url.format({
    pathname: path.join(__dirname, 'index.html'),
    protocol: 'file:',
    slashes: true,
  }));

  mainWindow.on('blur', hideWindow);

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.on('ready', createWindow);

app.on('window-all-closed', () => {
  app.quit();
});
