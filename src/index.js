import { init } from "./utils/init";
import { MDCRipple } from "@material/ripple";
import { MDCTopAppBar } from "@material/top-app-bar";
/*
 * this file is used to initialize application
 */
init();
// add a ripple effect to all the buttons
document
  .querySelectorAll(".mdc-button, .mdc-card__primary-action")
  .forEach(button => new MDCRipple(button));

const topAppBarElement = document.querySelector(".mdc-top-app-bar");
new MDCTopAppBar(topAppBarElement);
