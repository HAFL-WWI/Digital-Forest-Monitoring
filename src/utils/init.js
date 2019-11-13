import { MDCDialog } from "@material/dialog";
import { MDCRipple } from "@material/ripple";
import { MDCTopAppBar } from "@material/top-app-bar";
import { initRouter } from "./router";
import { dialogTitle, dialogContent, impressum } from "./main_util";
export const init = () => {
  //start the router
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
export const dialog = new MDCDialog(document.querySelector(".mdc-dialog"));
//add the event listener to the impressum button
document.getElementById("impressum-button").addEventListener("click", () => {
  dialogTitle.innerHTML = impressum.tite;
  dialogContent.innerHTML = impressum.content;
  dialog.open();
});
