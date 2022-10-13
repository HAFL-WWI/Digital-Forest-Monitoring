import { MDCDialog } from "@material/dialog";
import { MDCRipple } from "@material/ripple";
import { MDCTextField } from "@material/textfield";
import { MDCTextFieldIcon } from "@material/textfield/icon";
import { initRouter } from "./router";
import {
  removeGeojsonOverlays,
  searchResults,
  closeSidebar,
  updateTitle
} from "./main_util";
import viewerUtil from "./viewer_util";
import { register } from "ol/proj/proj4";
import { registerProjections } from "./projectionUtil";

export const init = () => {
  registerProjections(register);
  initRouter();
  /*
   * normalize css vh to have correct height on mobile devices.
   * credits: https://css-tricks.com/the-trick-to-viewport-units-on-mobile/
   */
  let vh = window.innerHeight * 0.01;
  //set the value in the --vh custom property to the root of the document
  document.documentElement.style.setProperty("--vh", `${vh}px`);
  window.addEventListener("resize", () => {
    // We execute the same script as before
    let vh = window.innerHeight * 0.01;
    document.documentElement.style.setProperty("--vh", `${vh}px`);
    /* the map height must be updated in order to have no empty
     * space on device rotation on mobile devices.
     */
    let updateMapsize;
    /*
     * the resize event got fired in an interval < 100ms
     * therefore we clear the timeout function to update
     * the map size.
     */
    clearTimeout(updateMapsize);

    updateMapsize = setTimeout(() => {
      /*
       * the code in here only get's called, when
       * the resize event did not get fired for 100ms.
       */
      viewerUtil.controller.updateMapHeight();
      /* hide the zoom control in landscape mode
       * cause it obscures the gps button.
       */
      const orientation = viewerUtil.controller.getOrientation();
      viewerUtil.controller.toggleZoomControl({
        orientation,
        zoomControl: viewerUtil.model.zoomControl
      });
    }, 100);
  });
};

document
  .querySelectorAll(".mdc-button, .mdc-card__primary-action")
  .forEach(el => {
    return new MDCRipple(el);
  });

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
  viewerUtil.controller.closeSearchResults(searchResults);
  textField.value = "";
  removeGeojsonOverlays(viewerUtil.model.map);
});

/*
 * init and handle events for the modal dialog
 */
export const dialog = new MDCDialog(document.querySelector(".mdc-dialog"));
document.getElementById("impressum-button").addEventListener("click", () => {
  dialog.open();
  window.translator.run();
});

/* event listener to set the map height when browser gets resized.
 * neccessary because is possible that the topAppBar change it's height.
 */
window.addEventListener("resize", () => {
  updateTitle();
});

/*
 * event listener to close the sidebar
 */
const sidebarClose = document.querySelector(".sidebar__close");
sidebarClose.addEventListener("click", closeSidebar);
