import React from 'react';
import ReactDOM from 'react-dom';
import { tldExists } from 'tldjs';
import transparentCSS from './css/transparent.css';

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
    this.handleDomReady = this.handleDomReady.bind(this);
    this.handleWillNavigate = this.handleWillNavigate.bind(this);
    this.handleEvents = this.handleEvents.bind(this);
    this.handleNavigateInPage = this.handleNavigateInPage.bind(this);
  }

  componentDidMount() {
    this.handleEvents(true);
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
      { name: 'dom-ready', handler: this.handleDomReady },
    ];

    const action = add ? 'addEventListener' : 'removeEventListener';

    this.events.forEach((event) => {
      this.webview[action](event.name, event.handler);
    });
  }

  handleWillNavigate(e) {
    this.setState({ location: e.url });
  }

  handleNavigateInPage(e) {
    if (e.isMainFrame) {
      this.setState({ location: e.url });
    }
  }

  handleDomReady() {
    this.webview.insertCSS(transparentCSS);
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

    return (
      <div className={`${showLoadingAnimation && 'loading'}`}>
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
          ref={(r) => { this.webview = r; }}
          src="https://www.google.com/"
          className="webview"
        />
      </div>
    );
  }
}

ReactDOM.render(
  <Browser />,
  document.getElementById('toolbar'),
);

export default Browser;
