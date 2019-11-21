import { MDCDialog } from "@material/dialog";
import { MDCRipple } from "@material/ripple";
import { MDCTopAppBar } from "@material/top-app-bar";
import { MDCTextField } from "@material/textfield";
import { MDCTextFieldIcon } from "@material/textfield/icon";
import { initRouter } from "./router";
import {
  dialogTitle,
  dialogContent,
  impressum,
  removeGeojsonOverlays,
  setTitle,
  getTitle,
  searchResults,
  closeSidebar
} from "./main_util";
import viewerUtil from "./viewer_util";

export const init = () => {
  initRouter();
};
const ripples = [].map.call(
  document.querySelectorAll(".mdc-button, .mdc-card__primary-action"),
  el => {
    return new MDCRipple(el);
  }
);

const topAppBarElement = document.querySelector(".mdc-top-app-bar");
new MDCTopAppBar(topAppBarElement);

/*
 * init and handle events for the search input
 */
export const textField = new MDCTextField(
  document.querySelector(".mdc-text-field")
);
textField.listen("input", viewerUtil.controller.performSearch);
textField.listen("keydown", e => {
  if (e.key === "ArrowDown") {
    const firstElement = document.getElementsByClassName("mdc-list-item")[0];
    firstElement.focus();
    window.requestAnimationFrame(() => {
      firstElement.scrollIntoView();
    });
  }
});
textField.listen("focusin", () => {
  textField.value = "";
});
const textFieldIcon = new MDCTextFieldIcon(
  document.querySelector(".text-field-clear__icon")
);
textFieldIcon.listen("click", () => {
  searchResults.style.transform = "scale(1,0)";
  textField.value = "";
  removeGeojsonOverlays(viewerUtil.model.map);
});

/*
 * init and handle events for the modal dialog
 */
export const dialog = new MDCDialog(document.querySelector(".mdc-dialog"));
document.getElementById("impressum-button").addEventListener("click", () => {
  dialogTitle.innerHTML = impressum.tite;
  dialogContent.innerHTML = impressum.content;
  dialog.open();
});

/* event listener to set the map height when browser gets resized.
 * neccessary because is possible that the topAppBar change it's height.
 */
window.addEventListener("resize", () => {
  setTitle(getTitle());
  const map = document.getElementById("map");
  if (map) {
    const topAppBar = document.querySelector(".mdc-top-app-bar");
    map.style.height = `calc(100vh - ${topAppBar.offsetHeight}px`;
  }
});

/*
 * event listener to close the sidebar
 */
const sidebarClose = document.querySelector(".sidebar__close");
sidebarClose.addEventListener("click", closeSidebar);
