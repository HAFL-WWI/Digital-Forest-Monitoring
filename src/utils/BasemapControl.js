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
    const layerImage = document.createElement("img");
    layerImage.src = this.showVegetation ? orthoImage : vegetationImage;
    layerImage.alt = "layers";
    layerImage.className = "layerIcon";
    basemapControl.appendChild(layerImage);
    basemapControl.className = "basemapControl";
    basemapControl.title = "Vegetationshöhe anzeigen";
    basemapControl.addEventListener(
      "click",
      () => {
        this.showVegetation = !this.showVegetation;
        // load the right image inside the basemapControl
        layerImage.src = this.showVegetation ? orthoImage : vegetationImage;
        if (this.showVegetation) {
          basemapControl.title = "Orthofoto anzeigen";
          this.vegetationshoehe.setVisible(true);
        } else {
          basemapControl.title = "Vegetationshöhe anzeigen";
          this.vegetationshoehe.setVisible(false);
        }
      },
      false
    );
    const basemapSwitch = new Control({ element: basemapControl });
    return basemapSwitch;
  }
}
export default BasemapControl;
