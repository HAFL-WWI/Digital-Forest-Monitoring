import { Map, View } from "ol";
import Control from "ol/control/Control";
import "ol/ol.css";
import { orthoBasemap, vegetationBasemap } from "./basemap_util";
import orthoImage from "../img/basemapOrtho.jpg";
import vegetationImage from "../img/basemapVegetation.jpg";
const viewerUtil = {
  model: {
    /*
     * the element with the homepage content.
     */
    content: document.getElementsByClassName("content")[0]
  },
  controller: {
    /*
     * calls the necessary functions to display the viewer.
     */
    init: () => {
      viewerUtil.controller.removeContent();
      viewerUtil.controller.createContainer();
      viewerUtil.controller.showViewer();
    },
    /*
     * removes 'old' content like homepage, services etc.
     */
    removeContent: () => {
      viewerUtil.model.content.innerHTML = "";
    },
    /*
     * displays the ol viewer
     */
    createContainer: () => {
      viewerUtil.model.viewerContainer = viewerUtil.view.getViewerContainer();
      viewerUtil.model.content.appendChild(viewerUtil.model.viewerContainer);
    },
    /*
     * display the ol viewer inside the viewer container
     */
    showViewer: () => {
      viewerUtil.model.map = new Map({
        view: new View({
          center: [829300, 5933555], //Bern
          zoom: 11,
          minZoom: 9,
          maxZoom: 21
        }),
        layers: [orthoBasemap],
        target: "map"
      });
      const basemapSwitch = new olBasemapSwitch(viewerUtil.model.map);
      viewerUtil.model.map.addControl(basemapSwitch.createBasemapControl());
      viewerUtil.model.map.addEventListener("click", e => console.log(e));
    }
  },
  view: {
    /*
     * creates a full width/height container for the  viewer
     */
    getViewerContainer: () => {
      const viewerContainer = document.createElement("div");
      viewerContainer.id = "map";
      viewerContainer.style.width = "100vw";
      viewerContainer.style.height = "calc(100vh - 64px)";
      return viewerContainer;
    }
  }
};
export default viewerUtil;

class olBasemapSwitch {
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
    basemapControl.title = "Hintergrundkarten";
    basemapControl.addEventListener(
      "click",
      () => {
        this.showVegetation = !this.showVegetation;
        // load the right image inside the basemapControl
        layerImage.src = this.showVegetation ? orthoImage : vegetationImage;
        const layers = this.map.getLayers();
        const vegetationshoehe = layers.item(1);
        if (vegetationshoehe) {
          layers.removeAt(1);
        } else {
          layers.insertAt(1, vegetationBasemap);
        }
      },
      false
    );
    const basemapSwitch = new Control({ element: basemapControl });
    return basemapSwitch;
  }
}
