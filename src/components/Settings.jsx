import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { remote } from 'electron'; // eslint-disable-line import/no-extraneous-dependencies
import './css/settings.css';

const win = remote.getCurrentWindow();

class Settings extends React.PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      settings: props.settings,
    };

    this.settings = [
      { name: 'mouseGesture', label: 'Enable mouse gesture' },
      { name: 'activationHotkey', label: 'Enable activation hotkey' },
      { name: 'escapeHotkey', label: 'Enable escape hotkey to close window' },
      { name: 'hideOnMouseOut', label: 'Enable mouse out to close window.' },
      { name: 'runAtStartup', label: 'Launch Ninja Browser at startup' },
    ];

    this.handleCheck = this.handleCheck.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleCheck(e) {
    const newSettings = {
      ...this.state.settings,
      [e.target.name]: e.target.checked,
    };

    this.setState({ settings: newSettings });
  }

  handleSubmit(e) {
    e.preventDefault();

    this.props.updateSettings(this.state.settings);
  }

  render() {
    const { settings } = this.state;
    return (
      <div>
        <h2>Settings</h2>
        <form onSubmit={this.handleSubmit}>
          {this.settings.map(setting => [
            <input
              type="checkbox"
              name={setting.name}
              checked={settings[setting.name]}
              onChange={this.handleCheck}
            />,
            ` ${setting.label}`,
            <br />,
          ])}
          <input type="submit" value="Save" className="saveButton" />
        </form>
      </div>
    );
  }
}

Settings.propTypes = {
  settings: PropTypes.shape({
    mouseGesture: PropTypes.bool,
    activationHotkey: PropTypes.bool,
    escapeHotkey: PropTypes.bool,
  }).isRequired,
  updateSettings: PropTypes.func.isRequired,
};

ReactDOM.render(
  <Settings
    settings={win.settings}
    updateSettings={settings => win.updateSettings(settings)}
  />,
  document.body,
);

export default Settings;
