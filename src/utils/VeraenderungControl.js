import { Control } from "ol/control";

class VeraenderungControl {
  constructor(map = null) {
    this.map = map;
  }

  /*
   * creates the whole layer control for the "jaehrliche veränderung" viewer.
   * @returns {HTMLElement} veraenderungControlElement - a div with all the necessary children.
   */
  createVeraenderungControl() {
    const veraenderungControlElement = document.createElement("div");
    const viewerTitle = document.createElement("div");
    viewerTitle.classList.add("veraenderungControl__title");
    viewerTitle.addEventListener("click", () => {
      const controlDisplay = controls.style.display;
      if (controlDisplay === "none") {
        controls.style.display = "flex";
        titleArrow.innerHTML = "keyboard_arrow_down";
      } else {
        controls.style.display = "none";
        titleArrow.innerHTML = "keyboard_arrow_up";
      }
    });
    const title = document.createElement("span");
    title.style.flexGrow = 1;
    title.style.fontSize = "18px";
    title.innerHTML = "Jährliche Veränderung";
    const titleArrow = document.createElement("i");
    titleArrow.classList.add("material-icons");
    titleArrow.innerHTML = "keyboard_arrow_down";
    veraenderungControlElement.className = "veraenderungControl";
    veraenderungControlElement.title = "Veraenderung control";
    viewerTitle.appendChild(title);
    viewerTitle.appendChild(titleArrow);
    veraenderungControlElement.appendChild(viewerTitle);
    const controls = document.createElement("div");
    controls.classList.add("veraenderungControl__controls");
    controls.appendChild(this.getSwitch());
    controls.appendChild(this.getLayerInfoIcon());
    controls.appendChild(this.getSlider());
    veraenderungControlElement.appendChild(controls);
    const veraenderungControl = new Control({
      element: veraenderungControlElement
    });
    return veraenderungControl;
  }
  /*
   * creates the layer info (i) icon
   * @returns {HTMLElement} layerInfo - the info icon.
   */
  getLayerInfoIcon() {
    const layerInfo = document.createElement("button");
    layerInfo.classList.add(
      "layerinfo-button",
      "mdc-icon-button",
      "material-icons"
    );
    layerInfo.innerHTML = "info";
    layerInfo.addEventListener("click", () => console.log("info clicked"));
    return layerInfo;
  }

  /*
   * creates the layer on/off switch
   * @returns {DocumentFragment} switchFragment- the labeled switch.
   */
  getSwitch() {
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
    input.id = "layer-switch";
    input.checked = true;
    input.setAttribute("role", "switch");
    input.addEventListener("change", e => {
      console.log("switch changed");
      console.log(e.target.checked);
    });
    label.for = "layer-switch";
    label.innerHTML = "Veränderung 2019";
    label.style.padding = "0 0 0 12px";
    label.style.flexGrow = 1;
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
  getSlider() {
    const sliderContainer = document.createElement("div");
    sliderContainer.classList.add("slidercontainer");
    const opacityIcon = document.createElement("i");
    opacityIcon.classList.add("material-icons");
    opacityIcon.innerHTML = "opacity";
    opacityIcon.title = "Transparenz";
    opacityIcon.style.padding = "0 12px 0 0";
    const slider = document.createElement("div");
    slider.id = "slider";
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

    return sliderContainer;
  }

  getDivider() {
    return document.createElement("hr");
  }
}
export default VeraenderungControl;
