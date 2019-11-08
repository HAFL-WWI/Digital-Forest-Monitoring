import { Control } from "ol/control";
import { vegetationBasemap } from "./basemap_util";
import orthoImage from "../img/basemapOrtho.jpg";
import vegetationImage from "../img/basemapVegetation.jpg";
class BasemapControl {
  constructor(map = null) {
    this.map = map;
    this.showVegetation = false;
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
        const layers = this.map.getLayers();
        const vegetationshoehe = layers.item(1);
        if (vegetationshoehe) {
          basemapControl.title = "Vegetationshöhe anzeigen";
          layers.removeAt(1);
        } else {
          basemapControl.title = "Orthofoto anzeigen";
          layers.insertAt(1, vegetationBasemap);
        }
      },
      false
    );
    const basemapSwitch = new Control({ element: basemapControl });
    return basemapSwitch;
  }
}
export default BasemapControl;
