import React from 'react';
import ReactDOM from 'react-dom';
import PropTypes from 'prop-types';
import { remote } from 'electron'; // eslint-disable-line import/no-extraneous-dependencies
import { tldExists } from 'tldjs';
import classNames from 'classnames';

const win = remote.getCurrentWindow();

class Browser extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      location: 'https://www.google.com/',
      isLoading: true,
      showLoadingAnimation: true,
      canGoBack: false,
      canGoForward: false,
    };

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleLoadStart = this.handleLoadStart.bind(this);
    this.handleLoadStop = this.handleLoadStop.bind(this);
    this.handleLoadRedirect = this.handleLoadRedirect.bind(this);
    this.handleLoadCommit = this.handleLoadCommit.bind(this);
    this.handleReload = this.handleReload.bind(this);
    this.handleStopReloadAnimation = this.handleStopReloadAnimation.bind(this);
    this.handleWillNavigate = this.handleWillNavigate.bind(this);
    this.handleEvents = this.handleEvents.bind(this);
    this.handleNavigateInPage = this.handleNavigateInPage.bind(this);
    this.handleMouseLeave = this.handleMouseLeave.bind(this);
    this.handleWindowHide = this.handleWindowHide.bind(this);
  }

  componentDidMount() {
    this.handleEvents(true);
  }

  componentWillReceiveProps() {
    // Reload webview to force the preload script to grab the new settings.
    this.webview.reload();
  }

  componentWillUnmount() {
    this.handleEvents(false);
  }

  handleEvents(add = true) {
    this.events = [
      { name: 'did-start-loading', handler: this.handleLoadStart },
      { name: 'will-navigate', handler: this.handleWillNavigate },
      { name: 'did-navigate-in-page', handler: this.handleNavigateInPage },
      { name: 'did-stop-loading', handler: this.handleLoadStop },
      { name: 'did-get-redirect-request', handler: this.handleLoadRedirect },
      { name: 'did-finish-load', handler: this.handleLoadCommit },
    ];

    const action = add ? 'addEventListener' : 'removeEventListener';
    const eventEmitterAction = add ? 'on' : 'off';

    this.events.forEach((event) => {
      this.webview[action](event.name, event.handler);
    });

    win.events[eventEmitterAction]('hide', this.handleWindowHide);
  }

  handleWindowHide(hidden) {
    this.webview.setAudioMuted(hidden);
  }

  handleMouseLeave() {
    this.props.hideWindow();
  }

  handleWillNavigate(e) {
    this.setState({ location: e.url });
  }

  handleNavigateInPage(e) {
    if (e.isMainFrame) {
      this.setState({ location: e.url });
    }
  }

  // We don't remove the loading class immediately, instead we let the animation
  // finish, so that the spinner doesn't jerkily reset back to the 0 position.
  handleStopReloadAnimation() {
    if (!this.state.isLoading) {
      this.setState({ showLoadingAnimation: false });
    }
  }

  handleLoadCommit() {
    this.setState({
      location: this.webview.getURL(),
      canGoBack: this.webview.canGoBack(),
      canGoForward: this.webview.canGoForward(),
    });
  }

  handleLoadRedirect(e) {
    if (e.newURL && e.isMainFrame) {
      this.setState({ location: e.newURL });
    }
  }

  handleLoadStart(e) {
    this.setState({ isLoading: true, showLoadingAnimation: true });
    if (!e.isTopLevel) {
      return;
    }

    this.setState({ location: e.url });
  }

  handleLoadStop() {
    this.setState({ isLoading: false });
  }

  handleSubmit(e) {
    e.preventDefault();
    // TODO: Remove trailing slash from room domains.
    let newUrl = this.state.location;
    if (tldExists(newUrl) && newUrl.split('.').length > 1 && newUrl.split('.')[0].length > 0) {
      // Add http to the url if it's missing.
      if (!/^https?/ig.test(newUrl)) {
        newUrl = `http://${newUrl}`;
      }
    } else {
      newUrl = `https://www.google.com/search?q=${newUrl}`;
    }

    this.webview.src = newUrl;
  }

  handleReload() {
    if (this.state.isLoading) {
      this.webview.stop();
    } else {
      this.webview.reload();
    }
  }

  render() {
    const {
      location,
      canGoBack,
      canGoForward,
      showLoadingAnimation,
    } = this.state;
    const { grayScaleWebpage } = this.props;

    return (
      <div className={`${showLoadingAnimation && 'loading'}`} onMouseLeave={this.handleMouseLeave}>
        <div id="controls">
          <button
            id="back"
            title="Go Back"
            disabled={!canGoBack}
            onClick={() => this.webview.goBack()}
          >
            &#9664;
          </button>
          <button
            id="forward"
            title="Go Forward"
            disabled={!canGoForward}
            onClick={() => this.webview.goForward()}
          >
            &#9654;
          </button>
          <button
            id="reload"
            title="Reload"
            onClick={this.handleReload}
            onAnimationIteration={this.handleStopReloadAnimation}
          >
            &#10227;
          </button>
          <form id="location-form" onSubmit={this.handleSubmit}>
            <div id="center-column">
              <input
                id="location"
                type="text"
                value={location}
                onChange={e => this.setState({ location: e.target.value })}
              />
            </div>
            <input type="submit" value="Go" />
          </form>
        </div>
        <webview
          className={classNames('webview', { grayscale: grayScaleWebpage })}
          ref={(r) => { this.webview = r; }}
          src="https://www.google.com/"
          preload="./dist/preload.js"
        />
      </div>
    );
  }
}

Browser.propTypes = {
  hideWindow: PropTypes.func.isRequired,
  grayScaleWebpage: PropTypes.bool.isRequired,
};

const renderBrowser = () => {
  ReactDOM.render(
    <Browser
      hideWindow={win.hideWindow}
      grayScaleWebpage={win.grayScaleWebpage}
    />,
    document.getElementById('toolbar'),
  );
};

renderBrowser();

win.events.on('sync', () => renderBrowser());

export default Browser;
