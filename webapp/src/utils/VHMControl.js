import { Control } from "ol/control";
import vegetationImage from "url:../img/basemapVegetation.jpg";
import { vegetationBasemap } from "./basemap_util";
class VHMControl {
  constructor(map = null) {
    this.map = map;
    this.showVegetation = false;
  }

  createVHMControl() {
    const vhmFragment = new DocumentFragment();
    const vhmControl = document.createElement("div");
    vhmFragment.appendChild(vhmControl);
    vhmControl.className = "vhmControl";
    vhmControl.style.backgroundImage = `url(${vegetationImage})`;
    const vhmTitle = document.createElement("div");
    vhmTitle.classList.add("vhmControl__title");
    vhmTitle.innerHTML = "VHM";
    const vhmText = document.createElement("div");
    vhmText.classList.add("vhm__text");
    vhmText.innerHTML = "Turn on";
    vhmControl.appendChild(vhmTitle);
    vhmControl.appendChild(vhmText);
    vhmControl.title = "Vegetationshöhe anzeigen";
    vhmControl.addEventListener(
      "click",
      e => {
        e.preventDefault();
        vhmControl.classList.remove("animate");
        /* triggering a reflow after the removing of the animate class,
         * will make the animation work withou a setTimeout().
         */
        void vhmControl.offsetWidth;
        vhmControl.classList.add("animate");
        this.showVegetation = !this.showVegetation;
        if (this.showVegetation) {
          vhmControl.title = "Vegetationshöhe ausblenden";
          vegetationBasemap.setVisible(true);
          vhmText.innerHTML = "Turn off";
        } else {
          vhmControl.Text = "Vegetationshöhe anzeigen";
          vegetationBasemap.setVisible(false);
          vhmText.innerHTML = "Turn on";
        }
      },
      false
    );
    const vhmSwitch = new Control({ element: vhmFragment });
    return vhmSwitch;
  }
}
export default VHMControl;
