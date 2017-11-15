const psl = require('psl');

const webview = document.querySelector('webview');
let isLoading = false;

function resetExitedState() {
  document.body.classList.remove('exited');
  document.body.classList.remove('crashed');
  document.body.classList.remove('killed');
}

function navigateTo(url) {
  resetExitedState();
  // TODO: Remove trailing slash from room domains.
  let realUrl = url;
  if (psl.isValid(realUrl)) {
    if (!/^https?:\/\//i.test(realUrl)) {
      realUrl = `http://${realUrl}`;
    }
  }

  document.querySelector('webview').src = realUrl;
}

function doLayout() {
  const controls = document.querySelector('#controls');
  const controlsHeight = controls.offsetHeight;
  const windowWidth = document.documentElement.clientWidth;
  const windowHeight = document.documentElement.clientHeight;
  const webviewWidth = windowWidth;
  const webviewHeight = windowHeight - controlsHeight;

  webview.style.width = `${webviewWidth}px`;
  webview.style.height = `${webviewHeight}px`;
}

function handleExit(event) {
  console.log(event.type);
  document.body.classList.add('exited');
  if (event.type === 'abnormal') {
    document.body.classList.add('crashed');
  } else if (event.type === 'killed') {
    document.body.classList.add('killed');
  }
}

function handleLoadCommit() {
  resetExitedState();
  const localWebview = document.querySelector('webview');
  document.querySelector('#location').value = localWebview.getURL();
  document.querySelector('#back').disabled = !localWebview.canGoBack();
  document.querySelector('#forward').disabled = !localWebview.canGoForward();
}

function handleLoadStart(event) {
  document.body.classList.add('loading');
  isLoading = true;

  resetExitedState();
  if (!event.isTopLevel) {
    return;
  }

  document.querySelector('#location').value = event.url;
}

function handleLoadStop() {
  // We don't remove the loading class immediately, instead we let the animation
  // finish, so that the spinner doesn't jerkily reset back to the 0 position.
  isLoading = false;
}

function handleLoadAbort(event) {
  console.log('LoadAbort');
  console.log(`  url: ${event.url}`);
  console.log(`  isTopLevel: ${event.isTopLevel}`);
  console.log(`  type: ${event.type}`);
}

function handleLoadRedirect(event) {
  const locationElement = document.querySelector('#location');
  resetExitedState();
  if (event.newURL && event.isMainFrame) {
    locationElement.value = event.newURL;
  }
}

window.onresize = doLayout;
doLayout();

document.querySelector('#back').onclick = function goBack() {
  webview.goBack();
};

document.querySelector('#forward').onclick = function goForward() {
  webview.goForward();
};

document.querySelector('#reload').onclick = function reload() {
  if (isLoading) {
    webview.stop();
  } else {
    webview.reload();
  }
};
document.querySelector('#reload').addEventListener(
  'webkitAnimationIteration',
  () => {
    if (!isLoading) {
      document.body.classList.remove('loading');
    }
  },
);

document.querySelector('#location-form').onsubmit = function onNavigate(e) {
  e.preventDefault();
  navigateTo(document.querySelector('#location').value);
};

webview.addEventListener('close', handleExit);
webview.addEventListener('did-start-loading', handleLoadStart);
webview.addEventListener('did-stop-loading', handleLoadStop);
webview.addEventListener('did-fail-load', handleLoadAbort);
webview.addEventListener('did-get-redirect-request', handleLoadRedirect);
webview.addEventListener('did-finish-load', handleLoadCommit);
