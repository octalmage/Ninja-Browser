import React from 'react';
import ReactDOM from 'react-dom';
import psl from 'psl';
import transparentCSS from './css/transparent.css';

class Browser extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      location: 'https://www.google.com/',
      isLoading: true,
      canGoBack: false,
      canGoForward: false,
    };

    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleLoadStart = this.handleLoadStart.bind(this);
    this.handleLoadStop = this.handleLoadStop.bind(this);
    this.handleLoadRedirect = this.handleLoadRedirect.bind(this);
    this.handleLoadCommit = this.handleLoadCommit.bind(this);
    this.handleReload = this.handleReload.bind(this);
  }

  componentDidMount() {
    // this.webview.addEventListener('close', handleExit);
    this.webview.addEventListener('did-start-loading', this.handleLoadStart);
    this.webview.addEventListener('did-stop-loading', this.handleLoadStop);
    // this.webview.addEventListener('did-fail-load', handleLoadAbort);
    this.webview.addEventListener('did-get-redirect-request', this.handleLoadRedirect);
    this.webview.addEventListener('did-finish-load', this.handleLoadCommit);
    this.webview.addEventListener('dom-ready', () => {
      this.webview.insertCSS(transparentCSS);
    });
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
    this.setState({ isLoading: true });
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
    let realUrl = this.state.location;
    if (psl.isValid(realUrl)) {
      if (!/^https?:\/\//i.test(realUrl)) {
        realUrl = `http://${realUrl}`;
      }
    } else {
      realUrl = `https://www.google.com/search?q=${realUrl}`;
    }

    this.webview.src = realUrl;
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
      isLoading,
    } = this.state;

    return (
      <div className={`${isLoading && 'loading'}`}>
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
