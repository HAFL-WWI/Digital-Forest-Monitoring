import { init } from "./utils/init";
import { MDCRipple } from "@material/ripple";
import { MDCTopAppBar } from "@material/top-app-bar";
import { MDCSwitch } from "@material/switch";
import { MDCSlider } from "@material/slider";

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

new MDCSwitch(document.querySelector(".mdc-switch"));

const slider = new MDCSlider(document.querySelector(".mdc-slider"));
slider.listen("MDCSlider:change", () =>
  console.log(`Value changed to ${slider.value}`)
);
