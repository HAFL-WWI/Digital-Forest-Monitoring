import { Control } from "ol/control";
import orthoImage from "../img/basemapOrtho.jpg";
import vegetationImage from "../img/basemapVegetation.jpg";
class BasemapControl {
  constructor(map = null) {
    this.map = map;
    this.showVegetation = false;
    this.vegetationshoehe = this.map.getLayers().item(1);
  }

  createBasemapControl() {
    const basemapControl = document.createElement("div");
    basemapControl.style.backgroundImage = `url(${vegetationImage})`;
    const basemapTitle = document.createElement("div");
    basemapTitle.classList.add("basemapControl__title");
    basemapTitle.innerHTML = "VHM";
    basemapControl.appendChild(basemapTitle);
    basemapControl.className = "basemapControl";
    basemapControl.title = "Vegetationshöhe anzeigen";
    basemapControl.addEventListener(
      "click",
      e => {
        e.preventDefault();
        basemapControl.classList.remove("animate");
        /* triggering a reflow after the removing of the animate class,
         * will make the animation work withou a setTimeout().
         */
        void basemapControl.offsetWidth;
        basemapControl.classList.add("animate");
        this.showVegetation = !this.showVegetation;
        // load the right image inside the basemapControl
        basemapControl.style.backgroundImage = this.showVegetation
          ? `url(${orthoImage})`
          : `url(${vegetationImage})`;
        if (this.showVegetation) {
          basemapControl.title = "Orthofoto anzeigen";
          this.vegetationshoehe.setVisible(true);
          basemapTitle.innerHTML = "Orthofoto";
        } else {
          basemapControl.title = "Vegetationshöhe anzeigen";
          this.vegetationshoehe.setVisible(false);
          basemapTitle.innerHTML = "VHM";
        }
      },
      false
    );
    const basemapSwitch = new Control({ element: basemapControl });
    return basemapSwitch;
  }
}
export default BasemapControl;
