/*
 * changes the top appbar title.
 * @param {string} title - the new title to display.
 * @returns {boolean} - true if title changed successfully, false otherwise.
 */
export const changeTitle = title => {
  console.log("change title called");
  if (!title) {
    return false;
  }
  document.getElementsByClassName(
    "mdc-top-app-bar__title"
  )[0].innerHTML = title;
  return true;
};

/*
 * updates the title in the appBar.
 * @param {string} title - the text that should be used as the title.
 * @returns void.
 */
export const setTitle = title => {
  document.getElementsByClassName(
    "mdc-top-app-bar__title"
  )[0].innerHTML = title;
};

/*
 * calculates the title based on the window.width.
 * @returns {string} title - title to use based on the current window.width.
 */
export const getTitle = () => {
  const width = window.innerWidth;
  const title =
    width <= 500
      ? "Waldmonitoring"
      : "Waldmonitoring mit Sentinel Satellitenbildern";
  return title;
};
