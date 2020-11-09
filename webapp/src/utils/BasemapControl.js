import { Control } from "ol/control";
import orthoImage from "url:../img/basemapOrtho.jpg";
import sw from "url:../img/sw.jpg";
import { orthoBasemap, swBasemap } from "./basemap_util";
import { updateUrl } from "./url_util";
class BasemapControl {
  constructor(map = null, active = "Orthofoto") {
    this.map = map;
    this.active = active;
    this.checkAndSetZoom(this.active);
    this.basemaps = [
      {
        name: "Orthofoto",
        visible: true,
        image: orthoImage,
        layer: orthoBasemap
      },
      { name: "Karte SW", visible: false, image: sw, layer: swBasemap }
    ];
  }

  createBasemapControl() {
    const [activeBasemap, iconBasemap] = this.getBasemapState(this.active);
    //show the currently active basemap
    activeBasemap.layer.setVisible(true);
    const basemapContainer = document.createElement("div");
    this.basemapControl = document.createElement("div");
    this.basemapControl.appendChild(this.createBasemap(iconBasemap));
    basemapContainer.appendChild(this.basemapControl);
    this.basemapControl.className = "basemapControl";
    const basemapSwitch = new Control({ element: basemapContainer });
    return basemapSwitch;
  }
  /*
   * creates a clickable basemap item
   * @param {object} basemapObject -  with important properties like name,image,visible ...
   * @returns {domElement} besemap - a clickable basemap div.
   */
  createBasemap(basemapObject) {
    const basemap = document.createElement("div");
    basemap.title = basemapObject.visible
      ? "Verfügbare Hintergrundkarten anzeigen"
      : "Hintergrundkarte wechseln";
    basemap.classList.add("basemap");
    basemap.style.backgroundImage = `url(${basemapObject.image})`;
    const basemapTitle = document.createElement("div");
    basemapTitle.classList.add("basemapControl__title");
    basemapTitle.innerHTML = basemapObject.name;
    basemap.appendChild(basemapTitle);
    basemap.addEventListener(
      "click",
      e => {
        e.preventDefault();
        this.basemapControl.classList.remove("animate");
        /* triggering a reflow after the removing of the animate class,
         * will make the animation work withou a setTimeout().
         */
        void this.basemapControl.offsetWidth;
        this.basemapControl.classList.add("animate");
        const [newBasemap, iconBasemap] = this.getBasemapState(
          basemapObject.name
        );
        //set a new zoom for the basemap if necessary
        this.checkAndSetZoom(newBasemap.name);
        updateUrl({ basemap: newBasemap.name });
        this.basemapControl.firstChild.remove();
        this.basemapControl.appendChild(this.createBasemap(iconBasemap));
        iconBasemap.layer.setVisible(false);
        newBasemap.layer.setVisible(true);
      },
      false
    );

    return basemap;
  }
  /*
   * gets the basemap object to display on the map and the one to display in the switch
   * @param {string} basemapName - the name of the clicked basemap, e.g. the new basemap to display
   * @returns {array} - the new basemap to display and the one to show in the basemap toggle.
   */
  getBasemapState(basemapName) {
    const newBasemap = this.basemaps.filter(
      item => item.name === basemapName
    )[0];
    const iconBasemap = this.basemaps.filter(
      item => item.name !== basemapName
    )[0];
    return [newBasemap, iconBasemap];
  }

  /*
   * check zoom scales for a certain basemap
   * @param {string} basemap - the basemap to check the zoom.
   * @returns {number} zoom - the zoom to set for the basemap.
   */
  checkZoom(basemap, zoom) {
    switch (basemap) {
      case "Orthofoto":
        return zoom <= 20 ? zoom : 20;
      case "Karte SW":
        return zoom <= 19 ? zoom : 19;
      default:
        return zoom;
    }
  }

  /*
   * checks if the current zoom is ok for a particular basemap and
   * if not, set the zoom to the maximum value for the basemap.
   * @param {string} basemap - the basemap to check.
   * @returns {number} newZoom - the zoom that was set.
   */
  checkAndSetZoom(basemap) {
    //set a new zoom for the basemap if necessary
    const zoom = this.map.getView().getZoom();
    const newZoom = this.checkZoom(basemap, zoom);
    if (zoom !== newZoom) {
      this.map.getView().setZoom(newZoom);
    }
    return newZoom;
  }
}
export default BasemapControl;
