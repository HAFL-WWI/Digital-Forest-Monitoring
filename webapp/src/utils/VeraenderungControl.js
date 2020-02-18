import { Control } from "ol/control";
import TileLayer from "ol/layer/Tile";
import { TileWMS } from "ol/source";
import { MDCSlider } from "@material/slider";
import { getLayerInfo, openSidebar } from "./main_util";
class VeraenderungControl {
  constructor({ map, title }) {
    this.map = map;
    this.title = title;
    this.overlays = [
      {
        layername: "karten-werk:ndvi_max_ch_forest_diff_2018_2017_decrease",
        displayName: "Vegetationsabnahme 17/18",
        description: `Difference between NDVI Maximum of 2018 and 2017, clipped to forest areas, Switzerland (expect small area in SW):
        Sentinel-2 NDVI maximum June & July for 2017
        Sentinel-2 NDVI maximum June & July for 2018
        This layer displays only areas where the ndvi has decresed e.g. areas of vegetation loss.
        Difference between 2018-2017`,
        visible: false
      }
    ];
  }

  /*
   * creates the whole layer control for the "jaehrliche veränderung" viewer.
   * @returns {HTMLElement} veraenderungControlElement - a div with all the necessary children.
   */
  createVeraenderungControl() {
    const veraenderungFragment = new DocumentFragment();
    //title section
    const viewerTitle = document.createElement("div");
    viewerTitle.classList.add("veraenderungControl__title");
    viewerTitle.addEventListener("click", () => {
      const controlsHeight = layerControls.getBoundingClientRect().height;
      if (controlsHeight === 0) {
        layerControls.style.transform = "scale(1,1)";
        layerControls.style.opacity = 1;
        titleArrow.style.transform = "rotate(0deg)";
      } else {
        layerControls.style.opacity = 0;
        layerControls.style.transform = "scale(1,0)";
        titleArrow.style.transform = "rotate(-90deg)";
      }
    });
    const title = document.createElement("span");
    title.style.flexGrow = 1;
    title.style.fontSize = "17px";
    title.innerHTML = this.title;
    const titleIcon = document.createElement("i");
    titleIcon.classList.add("material-icons");
    titleIcon.innerHTML = "tune";
    const titleArrow = document.createElement("i");
    titleArrow.classList.add("material-icons", "title__arrow");
    titleArrow.innerHTML = "keyboard_arrow_down";
    title.title = "Schaltflächen anzeigen";
    viewerTitle.appendChild(title);
    viewerTitle.appendChild(titleIcon);
    viewerTitle.appendChild(titleArrow);

    // add layers and controls
    const layerControls = this.getLayerControls();

    veraenderungFragment.appendChild(viewerTitle);
    veraenderungFragment.appendChild(layerControls);
    const veraenderungControl = new Control({
      element: veraenderungFragment
    });
    return veraenderungControl;
  }

  getLayerControls() {
    const controls = document.createElement("div");
    controls.classList.add("veraenderungControl__controls");
    this.overlays.forEach(overlay => {
      const wmsLayer = this.createWmsLayer(overlay);
      this.map.addLayer(wmsLayer);
      const control = document.createElement("div");
      control.classList.add("veraenderungControl__controls-control");
      control.appendChild(this.getSwitch({ wmsLayer, overlay }));
      control.appendChild(this.getLayerInfoIcon(overlay));
      control.appendChild(this.getSlider(wmsLayer));
      controls.appendChild(control);
    });
    return controls;
  }
  /*
   * creates a ol wms overlay for a geoserver layer.
   * @param {object} overlay - overlay object like stored in the model.
   * @returns {object} TileLayer - ol.TileLayer instance.
   */
  createWmsLayer(overlay) {
    const url = "https://geoserver.karten-werk.ch/wms";
    const wmsLayer = new TileLayer({
      opacity: 1,
      source: new TileWMS({
        url: url,
        params: {
          LAYERS: `${overlay.layername}`,
          FORMAT: "image/png",
          SRS: "EPSG:3857"
          //TILED: true
        },
        serverType: "geoserver",
        //do not fade tiles:
        transition: 0
      })
    });
    wmsLayer.name = `${overlay.layername}`;
    wmsLayer.setVisible(overlay.visible);
    return wmsLayer;
  }
  /*
   * creates the layer info (i) icon
   * @param {object} overlay - overlay item like stored in this.overlays
   * @returns {HTMLElement} layerInfo - the info icon.
   */
  getLayerInfoIcon(overlay) {
    const layerInfo = document.createElement("button");
    layerInfo.classList.add(
      "layerinfo-button",
      "mdc-icon-button",
      "material-icons"
    );
    layerInfo.innerHTML = "info";
    layerInfo.addEventListener("click", () => {
      const content = new DocumentFragment();
      const title = document.createElement("h3");
      title.innerHTML = `${overlay.displayName}`;
      const description = document.createElement("div");
      description.innerHTML = getLayerInfo(overlay);
      content.appendChild(title);
      content.appendChild(description);
      openSidebar({ content });
    });
    return layerInfo;
  }

  /*
   * creates the layer on/off switch
   * @returns {DocumentFragment} switchFragment- the labeled switch.
   */
  getSwitch({ wmsLayer, overlay } = {}) {
    const switchFragment = new DocumentFragment();
    const layerSwitch = document.createElement("div");
    const switchTrack = document.createElement("div");
    const thumbUnderlay = document.createElement("div");
    const thumb = document.createElement("div");
    const input = document.createElement("input");
    const label = document.createElement("label");
    layerSwitch.classList.add("mdc-switch");
    switchTrack.classList.add("mdc-switch__track");
    thumbUnderlay.classList.add("mdc-switch__thumb-underlay");
    thumb.classList.add("mdc-switch__thumb");
    input.classList.add("mdc-switch__native-control");
    input.type = "checkbox";
    input.id = `${overlay.layername}_switch`;
    input.checked = overlay.visible;
    input.setAttribute("role", "switch");
    if (wmsLayer && overlay.displayName) {
      input.addEventListener("change", e => {
        wmsLayer.setVisible(e.target.checked);
      });
    }

    label.for = "layer-switch";
    label.innerHTML = `${overlay.displayName}`;
    label.style.padding = "0 0 0 12px";
    label.style.flexGrow = 1;
    label.style.fontSize = "12px";
    thumb.appendChild(input);
    thumbUnderlay.appendChild(thumb);
    layerSwitch.appendChild(switchTrack);
    layerSwitch.appendChild(thumbUnderlay);
    switchFragment.appendChild(layerSwitch);
    switchFragment.appendChild(label);
    return switchFragment;
  }
  /*
   * creates the layer transparency slider
   * @returns {DocumentFragment} slider - transparency slider.
   */
  getSlider(wmsLayer) {
    const sliderContainer = document.createElement("div");
    sliderContainer.classList.add("slidercontainer");
    const opacityIcon = document.createElement("i");
    opacityIcon.classList.add("material-icons");
    opacityIcon.innerHTML = "opacity";
    opacityIcon.title = "Transparenz";
    opacityIcon.style.padding = "0 12px 0 0";
    const slider = document.createElement("div");
    slider.id = `${wmsLayer.name}_slider`;
    slider.title = "Transparenz";
    const trackContainer = document.createElement("div");
    const track = document.createElement("div");
    const thumbContainer = document.createElement("div");
    const thumbContainerContent = `<div class="mdc-slider__pin"><span class="mdc-slider__pin-value-marker">
    </span></div><svg class="mdc-slider__thumb" width="21" height="21">
    <circle cx="10.5" cy="10.5" r="7.875"></circle></svg><div class="mdc-slider__focus-ring"></div>`;
    slider.classList.add("mdc-slider", "mdc-slider--discrete");
    slider.tabIndex = "0";
    slider.setAttribute("role", "slider");
    slider.setAttribute("aria-valuemin", "0");
    slider.setAttribute("aria-valuemax", "100");
    slider.setAttribute("aria-valuenow", "100");
    slider.setAttribute("ariaLabel", "transparency slider");

    trackContainer.classList.add("mdc-slider__track-container");
    track.classList.add("mdc-slider__track");
    thumbContainer.classList.add("mdc-slider__thumb-container");

    thumbContainer.innerHTML = thumbContainerContent;
    trackContainer.appendChild(track);
    slider.appendChild(trackContainer);
    slider.appendChild(thumbContainer);
    sliderContainer.appendChild(opacityIcon);
    sliderContainer.appendChild(slider);
    const mdcslider = new MDCSlider(slider);

    mdcslider.listen("MDCSlider:input", e => {
      const opacity = parseFloat(e.target.getAttribute("aria-valuenow") / 100);
      wmsLayer.setOpacity(opacity);
    });
    return sliderContainer;
  }

  getDivider() {
    return document.createElement("hr");
  }
}
export default VeraenderungControl;
