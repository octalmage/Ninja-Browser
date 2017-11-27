const { exec, getBinPath } = require('./utilities');

const getElements = getBinPath('dist/getElements');

module.exports = function getLargestElement() {
  return new Promise(async (resolve, reject) => {
    let elements;
    try {
      elements = JSON.parse(await exec(getElements));
    } catch (e) {
      return reject(e);
    }

    let bestElement = null;
    let bestArea = 0;
    const elementsLength = elements.length;
    for (let i = 0; i < elementsLength; i += 1) {
      const element = elements[i];
      if (![
        '',
        'AXWindow', // Exclude windows, use these as a last resort.
        'AXMenu', // Menus aren't a great choice.
        'AXMenuBar', // This is the menu bar at the top, also not good.
        'AXMenuBarItem', // Related to above.
        'AXSplitGroup', // This means that it has children, and they might be better picks.
      ].includes(element.role)) {
        const newArea = element.height * element.width;
        if (newArea > bestArea) {
          bestElement = element;
          bestArea = newArea;
        }
      }
    }

    /**
    *  TODO: Look for AXCloseButton subRole and use that to help fix windows
    *  that have custom menu bars.
    */
    // TODO: Make sure bestElement doesn't match window size, if it does shrink it.

    // Check to make sure the element is large enough.
    if (!bestElement || bestElement.width < 100 || bestElement.height < 100) {
      ([bestElement] = elements.filter(element => ['AXWindow', 'AXStandardWindow'].includes(element.role)));
      // Account for menu bar.
      bestElement.y += 20;
      bestElement.height -= 20;
    }

    return resolve(bestElement);
  });
};
