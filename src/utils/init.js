import { MDCDialog } from "@material/dialog";
import { initRouter } from "./router";
export const init = () => {
  //start the router
  initRouter();
  //set the title based on screen size
  setTitle(getTitle());
  //update the title if screen resizes
  window.addEventListener("resize", () => {
    setTitle(getTitle());
  });
};
//add the event listener to the impressum button
const dialog = new MDCDialog(document.querySelector(".mdc-dialog"));
document.getElementById("impressum-button").addEventListener("click", () => {
  dialog.open();
});

/*
 * updates the title in the appBar.
 * @param {string} title - the text that should be used as the title.
 * @returns void.
 */
const setTitle = title => {
  document.getElementsByClassName(
    "mdc-top-app-bar__title"
  )[0].innerHTML = title;
};

/*
 * calculates the title based on the window.width.
 * @returns {string} title - title to use based on the current window.width.
 */
const getTitle = () => {
  const width = window.innerWidth;
  const title =
    width <= 500
      ? "Waldmonitoring"
      : "Waldmonitoring mit Sentinel Satellitenbildern";
  return title;
};
