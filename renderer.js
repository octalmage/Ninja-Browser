
function navigateTo(url) {
  resetExitedState();
  document.querySelector('webview').src = url;
}

function doLayout() {
  const webview = document.querySelector('webview');
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
  if (event.type == 'abnormal') {
    document.body.classList.add('crashed');
  } else if (event.type == 'killed') {
    document.body.classList.add('killed');
  }
}

function resetExitedState() {
  document.body.classList.remove('exited');
  document.body.classList.remove('crashed');
  document.body.classList.remove('killed');
}

function handleLoadCommit() {
  resetExitedState();
  const webview = document.querySelector('webview');
  document.querySelector('#location').value = webview.getURL();
  document.querySelector('#back').disabled = !webview.canGoBack();
  document.querySelector('#forward').disabled = !webview.canGoForward();
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

function handleLoadStop(event) {
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
  resetExitedState();
  document.querySelector('#location').value = event.newUrl;
}


const validateUrl = value =>
  /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(value);

window.onresize = doLayout;
let isLoading = false;

const webview = document.querySelector('webview');
doLayout();

document.querySelector('#back').onclick = function () {
  webview.goBack();
};

document.querySelector('#forward').onclick = function () {
  webview.goForward();
};

document.querySelector('#reload').onclick = function () {
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

document.querySelector('#location-form').onsubmit = function (e) {
  e.preventDefault();
  navigateTo(document.querySelector('#location').value);
};

webview.addEventListener('close', handleExit);
webview.addEventListener('did-start-loading', handleLoadStart);
webview.addEventListener('did-stop-loading', handleLoadStop);
webview.addEventListener('did-fail-load', handleLoadAbort);
webview.addEventListener('did-get-redirect-request', handleLoadRedirect);
webview.addEventListener('did-finish-load', handleLoadCommit);
