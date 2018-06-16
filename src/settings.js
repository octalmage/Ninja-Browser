const settings = require('electron-settings');

const defaultSettings = [
  {
    name: 'mouseGesture',
    label: 'Enable mouse gesture to activate browser',
    default: true,
    section: 'General',
  },
  {
    name: 'activationHotkey',
    label: 'Enable hotkey to activate browser',
    default: true,
    section: 'General',
  },
  {
    name: 'escapeHotkey',
    label: 'Enable escape hotkey to hide browser',
    default: false,
    section: 'General',
  },
  {
    name: 'hideOnMouseOut',
    label: 'Enable mouse out to hide browser',
    default: true,
    section: 'General',
  },
  {
    name: 'runAtStartup',
    label: 'Launch Ninja Browser at startup',
    default: false,
    section: 'General',
  },
  {
    name: 'transparentImages',
    label: 'Make images transparent',
    default: true,
    section: 'Hiding Options',
  },
  {
    name: 'grayScaleWebpage',
    label: 'Make webpage grayscale',
    default: true,
    section: 'Hiding Options',
  },
];

module.exports.defaultSettings = defaultSettings;

module.exports.getSettings = function getSettings() {
  const builtSettings = {};
  defaultSettings.forEach((setting) => {
    builtSettings[setting.name] = settings.get(setting.name, setting.default);
  });
  return builtSettings;
};

module.exports.saveSettings = settings.setAll.bind(settings);
