import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { remote } from 'electron'; // eslint-disable-line import/no-extraneous-dependencies
import './css/settings.css';

const win = remote.getCurrentWindow();

class Settings extends React.PureComponent {
  // https://stackoverflow.com/a/34890276
  static groupBy(xs, key) {
    return xs.reduce((rv, x) => {
      const newRv = rv;
      (newRv[x[key]] = newRv[x[key]] || []).push(x);
      return newRv;
    }, {});
  }
  constructor(props) {
    super(props);

    this.state = {
      settings: props.settings,
    };

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
    const { settingsLabels } = this.props;

    const groupedSettings = Settings.groupBy(settingsLabels, 'section');

    return (
      <div>
        <h2>Settings</h2>
        <form onSubmit={this.handleSubmit}>
          {Object.keys(groupedSettings).map(section => [
            <h3>{section}</h3>,
            groupedSettings[section].map(setting => [
              <input
                type="checkbox"
                name={setting.name}
                checked={settings[setting.name]}
                onChange={this.handleCheck}
              />,
              ` ${setting.label}`,
              <br />,
            ]),
          ])
        }
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
  settingsLabels: PropTypes.arrayOf(PropTypes.shape({
    name: PropTypes.string,
    label: PropTypes.string,
  })).isRequired,
};

ReactDOM.render(
  <Settings
    settings={win.settings}
    updateSettings={settings => win.updateSettings(settings)}
    settingsLabels={win.settingsLabels}
  />,
  document.body,
);

export default Settings;
