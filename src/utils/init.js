import { MDCDialog } from "@material/dialog";
import { initRouter } from "./router";
export const init = () => {
  //start the router
  initRouter();
};
//add the event listener to the impressum button
const dialog = new MDCDialog(document.querySelector(".mdc-dialog"));
document.getElementById("impressum-button").addEventListener("click", () => {
  dialog.open();
});
