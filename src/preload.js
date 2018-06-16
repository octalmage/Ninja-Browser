import { getSettings } from './settings';
import transparentCSS from './components/css/webview/transparent.css';

function addStyleString(str) {
  const node = document.createElement('style');
  node.innerHTML = str;
  document.head.appendChild(node);
}

function addStyles() {
  if (document.body) {
    const { transparentImages } = getSettings();
    if (transparentImages) {
      addStyleString(transparentCSS);
    }
  } else {
    setTimeout(addStyles, 10);
  }
}

addStyles();
