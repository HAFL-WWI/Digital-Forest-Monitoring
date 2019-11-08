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
    const title = document.createElement("h3");
    title.style.marginTop = 0;
    title.style.width = "100%";
    veraenderungControlElement.className = "veraenderungControl";
    veraenderungControlElement.title = "Veraenderung control";
    title.innerHTML = "Jährliche Veränderung";
    veraenderungControlElement.appendChild(title);
    veraenderungControlElement.appendChild(this.getSwitch());
    veraenderungControlElement.appendChild(this.getLayerInfoIcon());
    veraenderungControlElement.appendChild(this.getSlider());

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
    const layerInfo = document.createElement("i");
    layerInfo.classList.add("material-icons");
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
    input.role = "switch";
    input.addEventListener("change", e => {
      console.log("switch changed");
      console.log(e.target.checked);
    });
    label.for = "layer-switch";
    label.innerHTML = "Veränderung 2019";
    label.style.padding = "0 0 0 8px";
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
    const label = document.createElement("label");
    label.setAttribute("for", "slider");
    label.innerHTML = "Transparenz";
    label.style.padding = "0 8px 0 0";
    label.style.fontSize = "12px";
    const slider = document.createElement("div");
    slider.id = "slider";
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
    sliderContainer.appendChild(label);
    sliderContainer.appendChild(slider);
    return sliderContainer;
  }
}
export default VeraenderungControl;
