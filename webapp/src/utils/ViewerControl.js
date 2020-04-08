import { Control } from "ol/control";
import { WMSCapabilities } from "ol/format";
import { transform } from "ol/proj";
import TileLayer from "ol/layer/Tile";
import { TileWMS } from "ol/source";
import { MDCSlider } from "@material/slider";
import { MDCSwitch } from "@material/switch";
import { MDCChipSet, MDCChip } from "@material/chips";
import { MDCSelect } from "@material/select";
import { getLayerInfo, openSidebar } from "./main_util";

class ViewerControl {
  constructor({ map, title }) {
    this.map = map;
    this.title = title;
    this.nbr_change = "karten-werk:nbr_change_T32TMT";
    this.uc1description = `Hinweiskarte für Waldveränderungen (z.B. Holzschläge) 
      auf Basis von Sentinel-2-Satellitenbildern. Die Werte in der Legende 
      beschreiben die Abnahme des <a href="https://de.wikipedia.org/wiki/Normalized_Difference_Vegetation_Index"> NDVI Vegetationsindex</a> zwischen den zwei 
      Zeitpunkten. Werte näher bei -1 weisen auf stärkere Waldveränderungen (z.B. Räumungen) hin.`;
    this.uc3description = `Hinweiskarte für die Veränderung der Vitalität in Bezug zum Medianwert seit 2015. 
    Dargestellt sind standardisierte NDVI-Werte (Sentinel-2-Satellitenbilder). Negative Werte deuten auf eine
     Abnahme der Vitalität hin, positive Werte deuten auf eine Zunahme der Vitalität hin. 
     Je tiefer bzw. höher die Werte sind, desto wahrscheinlicher ist es, dass eine effektive Veränderung stattfand. 
     Potenzielle Fehlerquellen sind Wolken und andere atmosphärische Störungen.`;
    this.changeOverlays = [
      {
        layername: "karten-werk:ndvi_decrease_2019_2018",
        displayName: "Juni 2018 - Juni 2019",
        description: this.uc1description,
        visible: true,
        toc: false
      },
      {
        layername: "karten-werk:ndvi_decrease_2018_2017",
        displayName: "Juni 2017 - Juni 2018",
        description: this.uc1description,
        visible: false,
        toc: false
      },
      {
        layername: "karten-werk:ndvi_decrease_2017_2016",
        displayName: "Juni 2016 - Juni 2017",
        description: this.uc1description,
        visible: false,
        toc: false
      }
    ];
    this.month = [
      { number: "01-02", text: "Jan/Feb" },
      { number: "02-03", text: "Feb/Mrz" },
      { number: "03-04", text: "Mrz/Apr" },
      { number: "04-05", text: "Apr/Mai" },
      { number: "05-06", text: "Mai/Jun" },
      { number: "06-07", text: "Jun/Jul" },
      { number: "07-08", text: "Jul/Aug" },
      { number: "08-09", text: "Aug/Sep" },
      { number: "09-10", text: "Sep/Okt" },
      { number: "10-11", text: "Okt/Nov" },
      { number: "11-12", text: "Nov/Dez" },
      { number: "12-01", text: "Dez/Jan" }
    ];
    this.vitalityLayers = [
      {
        year: "2019",
        month: this.month.slice(5, 8)
      },
      { year: "2018", month: this.month.slice(5, 8) }
    ];
    this.activeLayers = [];
  }

  /*
   * creates an object which can be used to create a time based wms.
   * @param {string} time - iso date format e.g. "2017-08-25".
   * @returns {object} layer object to use in the createWmsLayer function.
   */
  getTimeLayerObject(date) {
    date = date.substring(0, 10);
    const fromDate = new Date(date);
    fromDate.setDate(fromDate.getDate() - 45);
    const from = fromDate.toLocaleDateString();
    const to = new Date(date).toLocaleDateString();
    return {
      layername: this.nbr_change,
      time: date || "2017-08-25",
      displayName: `Veränderung ${date}`,
      description: `Veränderungsflächen vom <strong>${from}</strong> bis zum <strong>${to}</strong>.`,
      visible: true,
      toc: false
    };
  }

  /*
   * creates an object which can be used to vitality wms.
   * @param {object} params - function parameter object.
   * @param {number} params.year - year of the vitality layer e.g. 2018.
   * @param {object} params.month - month of the vitality layer as number and text.
   * @returns {object} layer object to use in the createWmsLayer function.
   */
  getVitalityLayerObject({ year, month }) {
    return {
      layername: `kartenwerk:ndvi_anomaly_${year}_${month.number}`,
      displayName: `NDVI Anomalien ${month.number} ${year}`,
      description: this.uc3description,
      visible: true,
      toc: false
    };
  }

  /*
   * creates the whole layer control for the "jaehrliche veränderung" viewer.
   * @returns {HTMLElement} veraenderungControlElement - a div with all the necessary children.
   */
  createControl({ type }) {
    const veraenderungFragment = new DocumentFragment();
    //title section
    const viewerTitle = document.createElement("div");
    viewerTitle.classList.add("viewerControl__title");
    viewerTitle.addEventListener("click", () => {
      const controlsHeight = this.viewerControls.getBoundingClientRect().height;
      if (controlsHeight === 0) {
        this.viewerControls.style.transform = "scale(1,1)";
        this.viewerControls.style.opacity = 1;
        titleArrow.style.transform = "rotate(0deg)";
      } else {
        this.viewerControls.style.opacity = 0;
        this.viewerControls.style.transform = "scale(1,0)";
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
    // add the necessary controls for every viewer.
    switch (type) {
      case "Natürliche Störungen":
        this.viewerControls = this.getStoerungControls();
        break;
      case "Jährliche Veränderung":
        this.viewerControls = this.getVeraenderungControls();
        break;
      case "Vitalität der Wälder":
        this.viewerControls = this.getVitalityControls(this.vitalityLayers);
        break;
      default:
        return;
    }
    veraenderungFragment.appendChild(viewerTitle);
    if (this.viewerControls) {
      veraenderungFragment.appendChild(this.viewerControls);
    }
    const veraenderungControl = new Control({
      element: veraenderungFragment
    });
    return veraenderungControl;
  }

  /*
   * create the controls for the "Jährliche Veranderung" viewer.
   * @returns {htmlElement} - a div element with all the controls for the viewer.
   */
  getVeraenderungControls() {
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const dropdown = this.createLayerDropdown(this.changeOverlays);
    controls.appendChild(dropdown);
    const layers = document.createElement("div");
    layers.classList.add("layers");
    controls.appendChild(layers);
    // add the first layer to the toc and the map
    this.addLayer({ layer: this.changeOverlays[0], domContainer: layers });
    return controls;
  }

  /*
   * create the controls for the "Vitalität der Wälder" viewer.
   * @param {array} years - the years to display in the dropdown [{displayName:2019},...].
   * @returns {htmlElement} - a div element with all the controls for the viewer.
   */
  getVitalityControls(years) {
    const yearObjects = [];
    years.forEach(yearObj => yearObjects.push({ displayName: yearObj.year }));
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const monthChips = document.createElement("div");
    monthChips.classList.add("monthchips");
    const title = document.createElement("div");
    title.classList.add("chips-title");
    title.innerText = "Monate:";
    monthChips.appendChild(title);
    const chipsetEl = document.createElement("div");
    chipsetEl.classList.add("mdc-chip-set", "mdc-chip-set--filter");
    this.chipset = new MDCChipSet(chipsetEl);
    monthChips.appendChild(chipsetEl);
    const dropdown = this.createVitalityDropdown(yearObjects, chipsetEl);
    controls.appendChild(dropdown);
    const layers = document.createElement("div");
    layers.classList.add("layers");
    controls.appendChild(monthChips);
    controls.appendChild(layers);
    return controls;
  }

  /*
   * removes layers from the ol map.
   * @param {array} layers - array of layer objects.
   */
  removeMapOverlays(layers) {
    layers.forEach(layer => this.map.removeLayer(layer.wmsLayer));
  }

  /*
   * creates a material design dropdown component.
   * @param {string} label - the select label.
   * @returns {object} - 2 div elements {dropdownContainer:htmlElement, mdcSelect:htmlElement}
   */
  createMDCDropdown(label) {
    const dropdownContainer = document.createElement("div");
    dropdownContainer.classList.add("viewerControl__dropdown");
    const mdcSelect = document.createElement("div");
    mdcSelect.classList.add("mdc-select");
    const mdcSelectAnchor = document.createElement("div");
    mdcSelectAnchor.classList.add(
      "mdc-select__anchor",
      "viewerControl__layerselect"
    );
    const mdcSelectDropdownIcon = document.createElement("i");
    mdcSelectDropdownIcon.classList.add("mdc-select__dropdown-icon");
    mdcSelect.appendChild(mdcSelectAnchor);
    const mdcSelectText = document.createElement("div");
    mdcSelectText.classList.add("mdc-select__selected-text");
    const mdcSelectLabel = document.createElement("span");
    mdcSelectLabel.classList.add("mdc-floating-label");
    mdcSelectLabel.innerHTML = label;
    const mdcSelectRipple = document.createElement("div");
    mdcSelectRipple.classList.add("mdc-line-ripple");

    mdcSelectAnchor.appendChild(mdcSelectDropdownIcon);
    mdcSelectAnchor.appendChild(mdcSelectText);
    mdcSelectAnchor.appendChild(mdcSelectLabel);
    mdcSelectAnchor.appendChild(mdcSelectRipple);
    return { dropdownContainer, mdcSelect };
  }

  /*
   * creates the select menu for the dropdown component.
   * @param {object} params - function parameter object.
   * @param {array} params.items - the items to show in the dropdown list.
   * @param {htmlElement} params.mdcSelect - div element.
   * @param {htmlElement} params.dropdownContainer - div element.
   * @param {function} params.callback - function to call when select item get's clicked.
   * @returns {MDCSelect} select - MDCSelect element.
   */
  createSelectMenu({ items, mdcSelect, dropdownContainer, callback }) {
    const mdcSelectMenu = document.createElement("div");
    mdcSelectMenu.classList.add(
      "mdc-select__menu",
      "mdc-menu",
      "mdc-menu-surface"
    );
    const mdcList = document.createElement("ul");
    mdcList.classList.add("mdc-list");
    const listItems = this.createDropdownList(items);
    mdcList.appendChild(listItems);
    mdcSelectMenu.appendChild(mdcList);
    mdcSelect.appendChild(mdcSelectMenu);
    dropdownContainer.appendChild(mdcSelect);
    const select = new MDCSelect(mdcSelect);
    select.listen("MDCSelect:change", callback);
    return select;
  }

  /*
   * creates a dropdown menu with new layers which can be added to the map.
   * @param {array} layers - layer objects which must be available in the dropdown.
   * @returns {htmlElement} - dropdown menu with layers to choose.
   */
  createLayerDropdown(layers) {
    const { dropdownContainer, mdcSelect } = this.createMDCDropdown(
      "Layer hinzufügen"
    );
    const callback = event => {
      const layer = this.changeOverlays.filter(
        overlay => overlay.displayName === event.detail.value
      )[0];
      if (layer.toc === true) {
        console.log("layer allready in toc");
        return;
      }
      layer.visible = true;
      layer.toc = true;
      this.addLayer({ layer, domContainer: document.querySelector(".layers") });
    };
    this.createSelectMenu({
      items: layers,
      mdcSelect,
      dropdownContainer,
      callback
    });
    return dropdownContainer;
  }

  /*
   * creates the dropdown menu and chip logic for the vitality viewer.
   * @param {array} years - year objects with a displayName property.
   * @param {domElement} chipset - container for the chips.
   * @returns {domElement} dropdown menu with years to choose.
   */
  createVitalityDropdown(years, chipset) {
    const { dropdownContainer, mdcSelect } = this.createMDCDropdown(
      "Jahr wählen"
    );
    const callback = e => {
      chipset.innerHTML = "";
      const year = e.detail.value;
      const selectedYear = this.vitalityLayers.filter(
        layer => layer.year.toString() === year.toString()
      )[0];
      selectedYear.month.forEach(month => {
        const monthChipElement = this.createMonthChip(year, month);
        const layer = this.getVitalityLayerObject({ year, month });
        layer.chip = new MDCChip(monthChipElement);
        layer.chip.listen("click", () => {
          this.handleChipClick({ layer, singleLayer: false });
        });
        chipset.appendChild(monthChipElement);
        this.chipset.addChip(monthChipElement);
      });
    };
    const select = this.createSelectMenu({
      items: years,
      mdcSelect,
      dropdownContainer,
      callback
    });
    select.value = years[0].displayName;
    return dropdownContainer;
  }

  /*
   * creates the dropdown content with new layers which can be added to the map.
   * @param {array} layers - layer objects which must be available in the list.
   * @returns {documentFragement} - li elements.
   */
  createDropdownList(layers) {
    const list = new DocumentFragment();
    layers.forEach(layer => {
      const li = document.createElement("li");
      li.classList.add("mdc-list-item");
      li.setAttribute("data-value", layer.displayName);
      li.innerHTML = layer.displayName;
      list.appendChild(li);
    });
    return list;
  }

  /*
   * add a layer to the map and the toc.
   * @param {object} params - function parameter obejct.
   * @param {object} params.layer - layer object to produce overlays and control elements.
   * @param {htmlElement} params.domContainer - the container to prepend the layer control.
   * @returns {htmlElement} layerElement - html layer element.
   */
  addLayer({ layer, domContainer } = {}) {
    if (!layer || !domContainer) {
      return false;
    }
    layer.toc = true;
    layer.visible = true;
    if (!layer.wmsLayer) {
      layer.wmsLayer = this.createWmsLayer(layer);
    }
    this.map.addLayer(layer.wmsLayer);
    layer.domElement = this.createLayerControl(layer);
    domContainer.prepend(layer.domElement);
    return layer;
  }

  /*
   * remove a layer from the map and the toc.
   * @param {object} layer - layer object with neccessary params like wmsLayer and domElement.
   * @returns {object} layer - the layer object of the removed layer.
   */
  removeLayer(layer) {
    layer.toc = false;
    layer.visible = false;
    this.map.removeLayer(layer.wmsLayer);
    const layers = document.querySelector(".layers");
    if (layers.contains(layer.domElement)) {
      layers.removeChild(layer.domElement);
    }
    return layer;
  }

  /*
   * create a layer control element.
   * @param {object} layer - layer obejct.
   * @returns {htmlElement} layer - layer control.
   */
  createLayerControl(layer) {
    const layerControl = document.createElement("div");
    layerControl.classList.add("viewerControl__controls-control");
    layerControl.appendChild(this.getSwitch({ overlay: layer }));
    layerControl.appendChild(this.getLayerRemoveButton(layer));
    layerControl.appendChild(this.getSlider(layer.wmsLayer));
    if (this.title === "Natürliche Störungen") {
      layerControl.appendChild(this.getSentinelLink(layer));
    }
    layerControl.appendChild(this.getLayerInfoButton(layer));
    return layerControl;
  }

  /*
   * create the controls for the "Natürliche Störungen" viewer.
   */
  getStoerungControls() {
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const intro = document.createElement("div");
    intro.classList.add("viewerControl__helpertext");
    intro.innerHTML =
      "Wählen Sie ein Datum um Veränderungsflächen der letzten <br /><strong>45 Tage</strong> zu sehen.";
    controls.appendChild(intro);
    const yearInfo = document.createElement("div");
    yearInfo.classList.add("viewerControl__yearinfo");
    controls.appendChild(yearInfo);
    const dateChips = document.createElement("div");
    dateChips.classList.add("datechips");
    const chipsetEl = document.createElement("div");
    chipsetEl.classList.add("mdc-chip-set", "mdc-chip-set--filter");
    this.chipset = new MDCChipSet(chipsetEl);
    this.getDimensions().then(response => {
      const year = response[0].split("-")[0];
      yearInfo.innerHTML = `Jahr ${year}`;
      response.forEach(date => {
        const layer = this.getTimeLayerObject(date);
        const chipEl = this.createDateChip(date);
        layer.chip = new MDCChip(chipEl);
        layer.chip.listen("click", () => {
          this.handleChipClick({ layer });
        });
        chipsetEl.appendChild(chipEl);
        this.chipset.addChip(chipEl);
      });
    });
    const layers = document.createElement("div");
    layers.classList.add("layers");
    controls.appendChild(chipsetEl);
    controls.appendChild(layers);
    return controls;
  }

  /*
   * handles klick events on a chip.
   * @paran {object} layer - layer object to use in the createWmsLayer function.
   * @returns {void}
   */
  handleChipClick({ layer, singleLayer = true } = {}) {
    if (!layer) {
      return;
    }
    const { chip } = layer;
    const domContainer = document.querySelector(".layers");
    // remove the layer from the dom and the map if we are in singleLayer mode
    if (singleLayer) {
      domContainer.innerHTML = "";
      this.removeMapOverlays(this.activeLayers);
      this.unselectChips({ chipset: this.chipset, id: chip.id });
    }
    chip.selected = !chip.selected;
    if (chip.selected === false) {
      this.addLayer({
        layer,
        domContainer
      });
      this.activeLayers.push(layer);
    } else {
      this.removeLayer(layer);
    }
  }

  /*
   * unselect all chips, except the one with the id from the function parameter.
   * @param {object} params - function parameter object.
   * @param {MDLChipset} params.chipset - the set with all the chips.
   * @param {string} params.id - the id of the string that should be selected.
   * @returns {MDLChipset} - chipset with updated chips.
   */
  unselectChips({ chipset, id }) {
    chipset.chips.forEach(chip => {
      if (chip.id !== id) {
        chip.selected = false;
      }
    });
    return chipset;
  }

  /*
   * get all the available time dimensions for the nbr_change layer.
   * @returns {promise} - promise with all the available time strings.
   */
  getDimensions() {
    const url = "https://geoserver.karten-werk.ch/wms?request=getCapabilities";
    const parser = new WMSCapabilities();
    return fetch(url)
      .then(response => response.text())
      .then(text => {
        const result = parser.read(text);
        const layers = result.Capability.Layer.Layer;
        const nbr = layers.filter(layer => layer.Name === this.nbr_change)[0];
        //center the map to Nussbaumen TG.
        this.map.getView().setCenter([981812.91, 6044778.75]);
        const dimensions = nbr.Dimension[0].values.split(",");
        return dimensions;
      });
  }

  /*
   * create a single date chip for the "Natürliche Störungen" viewer.
   * @param {string} date - the text content of the chip.
   * @returns {htmlElement} chip - MDCChip markup.
   */
  createDateChip(date) {
    const printDate = date.substring(0, 10);
    const chip = document.createElement("button");
    chip.setAttribute("data-name", `${printDate}`);
    chip.classList.add("mdc-chip");
    const checkmark = document.createElement("span");
    checkmark.classList.add("mdc-chip__checkmark");
    checkmark.innerHTML = `<svg class="mdc-chip__checkmark-svg" viewBox="-2 -3 30 30">
    <path class="mdc-chip__checkmark-path" fill="none" stroke="black"
          d="M1.73,12.91 8.1,19.28 22.79,4.59"/>
  </svg>`;
    const content = document.createElement("span");
    content.classList.add("mdc-chip__text");
    content.innerHTML = this.formatDateString(printDate);
    chip.appendChild(checkmark);
    chip.appendChild(content);
    return chip;
  }

  /*
   * create a single month chip for the "Vitalität der Wälder" viewer.
   * @param {number} year - 2018, 2019....
   * @param {object} month - {monthNumber:"06-07":monthText:"Jun/Jul"}.
   * @returns {htmlElement} chip - MDCChip markup.
   */
  createMonthChip(year, month) {
    const chip = document.createElement("button");
    chip.setAttribute("data-month", `${year}_${month.number}`);
    chip.classList.add("mdc-chip");
    const checkmark = document.createElement("span");
    checkmark.classList.add("mdc-chip__checkmark");
    checkmark.innerHTML = `<svg class="mdc-chip__checkmark-svg" viewBox="-2 -3 30 30">
    <path class="mdc-chip__checkmark-path" fill="none" stroke="black"
          d="M1.73,12.91 8.1,19.28 22.79,4.59"/>
  </svg>`;
    const chipContent = document.createElement("span");
    chipContent.classList.add("mdc-chip__text");
    chipContent.innerHTML = month.text;
    chip.appendChild(checkmark);
    chip.appendChild(chipContent);
    return chip;
  }

  /*
   * creates a date string which can be used in a date chip e.g. 4.Apr.
   * @param {string} datestring - something like "2017-08-05".
   * @returns {string} result - string like "5.Apr."
   */
  formatDateString(datestring) {
    const monthstrings = [
      "Jan",
      "Feb",
      "Mrz",
      "Apr",
      "Mai",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Okt",
      "Nov",
      "Dez"
    ];
    const date = new Date(datestring);
    const day = date.getDate();
    const month = monthstrings[date.getMonth()];
    return `${day}.${month}.`;
  }

  /*
   * creates a ol wms overlay for a geoserver layer.
   * @param {object} overlay - overlay object like stored in the model.
   * @returns {object} TileLayer - ol.TileLayer instance.
   */
  createWmsLayer(overlay) {
    const url = "https://geoserver.karten-werk.ch/wms";
    const params = {
      LAYERS: `${overlay.layername}`,
      FORMAT: "image/png",
      SRS: "EPSG:3857"
    };
    if (overlay.time) {
      params.time = overlay.time;
    }
    const wmsLayer = new TileLayer({
      opacity: 1,
      source: new TileWMS({
        url,
        params,
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
   * creates the layer info (i) icon.
   * @param {object} overlay - overlay item like stored in this.changeOverlays.
   * @returns {HTMLElement} layerInfo - the info icon.
   */
  getLayerInfoButton(overlay) {
    const layerInfo = document.createElement("button");
    layerInfo.classList.add(
      "layer-button",
      "mdc-icon-button",
      "material-icons"
    );
    layerInfo.innerHTML = "info";
    layerInfo.title = "Layer Infos";
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

  getLayerRemoveButton(overlay) {
    const removeLayer = document.createElement("button");
    removeLayer.title = "Layer entfernen";
    removeLayer.classList.add(
      "layer-button",
      "mdc-icon-button",
      "material-icons"
    );
    removeLayer.innerHTML = "remove_circle";
    removeLayer.addEventListener("click", () => {
      this.removeLayer(overlay);
      if (overlay.chip) {
        overlay.chip.selected = false;
      }
    });
    return removeLayer;
  }

  /*
   * creates the sentinel link.
   * @param {object} layer - layer item like stored in this.changeOverlays.
   * @returns {HTMLElement} layerInfo - the info icon.
   */
  getSentinelLink(layer) {
    const sentinelLink = document.createElement("button");
    sentinelLink.classList.add(
      "layer-button",
      "mdc-icon-button",
      "material-icons"
    );
    sentinelLink.innerHTML = "satellite";
    sentinelLink.title = "Bild auf Sentinel Playground ansehen";
    sentinelLink.addEventListener("click", () => {
      const zoom = this.map.getView().getZoom();
      const [lng, lat] = transform(
        this.map.getView().getCenter(),
        "EPSG:3857",
        "EPSG:4326"
      );
      const url =
        `https://apps.sentinel-hub.com/sentinel-playground/?source=S2&` +
        `lat=${lat}&` +
        `lng=${lng}&` +
        `zoom=${zoom}&` +
        `preset=1-NATURAL-COLOR&` +
        `layers=B01,B02,B03&` +
        `maxcc=20&` +
        `gain=2.0&` +
        `gamma=1.0&` +
        `time=${layer.time}%7C${layer.time}&` +
        `showDates=true`;
      window.open(url);
    });
    return sentinelLink;
  }

  /*
   * creates the layer on/off switch.
   * @param {object} params - function parameter object.
   * @param {object} params.overlay - object like stored in this.changeOverlays but with a wmsLayer property.
   * @returns {DocumentFragment} switchFragment- the labeled switch.
   */
  getSwitch({ overlay } = {}) {
    const switchFragment = new DocumentFragment();
    const layerSwitch = document.createElement("div");
    layerSwitch.title = "Layer ein/aus";
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
    input.setAttribute("aria-checked", "true");
    if (overlay.wmsLayer && overlay.displayName) {
      input.addEventListener("change", e => {
        overlay.wmsLayer.setVisible(e.target.checked);
        input.setAttribute("aria-checked", e.target.checked.toString());
      });
    }
    label.setAttribute("for", `${overlay.layername}_switch`);
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
    window.requestAnimationFrame(() => {
      new MDCSwitch(layerSwitch);
    });
    return switchFragment;
  }

  /*
   * creates the layer transparency slider.
   * @param {ol/TileLayer} - openlayers tile overlay.
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
    slider.classList.add("mdc-slider", "mdc-slider--discrete");
    slider.tabIndex = "0";
    slider.setAttribute("role", "slider");
    slider.setAttribute("aria-valuemin", "0");
    slider.setAttribute("aria-valuemax", "100");
    slider.setAttribute("aria-valuenow", "100");
    slider.setAttribute("ariaLabel", "transparency slider");
    const trackContainer = document.createElement("div");
    const track = document.createElement("div");
    const thumbContainer = document.createElement("div");
    const thumbContainerContent = `<div class="mdc-slider__pin"><span class="mdc-slider__pin-value-marker">
    </span></div><svg class="mdc-slider__thumb" width="21" height="21">
    <circle cx="10.5" cy="10.5" r="7.875"></circle></svg><div class="mdc-slider__focus-ring"></div>`;
    trackContainer.classList.add("mdc-slider__track-container");
    track.classList.add("mdc-slider__track");
    thumbContainer.classList.add("mdc-slider__thumb-container");

    thumbContainer.innerHTML = thumbContainerContent;
    trackContainer.appendChild(track);
    slider.appendChild(trackContainer);
    slider.appendChild(thumbContainer);
    sliderContainer.appendChild(opacityIcon);
    sliderContainer.appendChild(slider);
    window.requestAnimationFrame(() => {
      const mdcslider = new MDCSlider(slider);
      mdcslider.listen("MDCSlider:input", e => {
        const opacity = parseFloat(
          e.target.getAttribute("aria-valuenow") / 100
        );
        wmsLayer.setOpacity(opacity);
      });
    });

    return sliderContainer;
  }
}
export default ViewerControl;
