import { Control } from "ol/control";
import vegetationImage from "url:../img/basemapVegetation.jpg";
import { vegetationBasemap } from "./basemap_util";
import { updateUrl, removeParam } from "./url_util";
class VHMControl {
  constructor(map = null, showVegetation = false) {
    this.map = map;
    this.showVegetation = showVegetation;
  }

  createVHMControl() {
    this.vhmControl = document.createElement("div");
    this.vhmControl.className = "vhmControl";
    this.vhmControl.style.backgroundImage = `url(${vegetationImage})`;
    const vhmTitle = document.createElement("div");
    vhmTitle.classList.add("vhmControl__title");
    vhmTitle.innerHTML = "VHM";
    this.vhmText = document.createElement("div");
    this.vhmText.classList.add("vhm__text");
    this.vhmText.innerHTML = "Turn on";
    this.vhmControl.appendChild(vhmTitle);
    this.vhmControl.appendChild(this.vhmText);
    this.vhmControl.title = "Vegetationshöhe anzeigen";
    this.vhmControl.addEventListener(
      "click",
      e => {
        e.preventDefault();
        this.vhmControl.classList.remove("animate");
        /* triggering a reflow after the removing of the animate class,
         * will make the animation work withou a setTimeout().
         */
        void this.vhmControl.offsetWidth;
        this.vhmControl.classList.add("animate");
        this.showVegetation = !this.showVegetation;
        if (this.showVegetation) {
          this.showVHM();
        } else {
          this.hideVHM();
        }
      },
      false
    );
    // display the vhm if it is turned on via url parameter.
    if (this.showVegetation) {
      this.showVHM();
    }
    const vhmSwitch = new Control({ element: this.vhmControl });
    return vhmSwitch;
  }
  showVHM() {
    this.vhmControl.title = "Vegetationshöhe ausblenden";
    vegetationBasemap.setVisible(true);
    this.vhmText.innerHTML = "Turn off";
    updateUrl({ vhm: "on" });
  }

  hideVHM() {
    this.vhmControl.Text = "Vegetationshöhe anzeigen";
    vegetationBasemap.setVisible(false);
    this.vhmText.innerHTML = "Turn on";
    removeParam("vhm");
  }
}
export default VHMControl;
