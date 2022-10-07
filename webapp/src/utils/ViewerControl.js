import { Control } from "ol/control";
import { WMSCapabilities, GeoJSON } from "ol/format";
import { transform } from "ol/proj";
import TileLayer from "ol/layer/Tile";
import VectorLayer from "ol/layer/Vector";
import { TileWMS, Vector as VectorSource } from "ol/source";
import { bbox as bboxStrategy } from "ol/loadingstrategy";
import { MDCSlider } from "@material/slider";
import { MDCSwitch } from "@material/switch";
import { MDCSelect } from "@material/select";
import {
  getLayerInfo,
  openSidebar,
  change_overlay_colors,
  setI18nAttribute
} from "./main_util";
import Crowdsourcing from "./Crowdsourcing";
import {
  addLayerToUrl,
  getQueryParams,
  removeLayerFromUrl,
  updateUrlVisibilityOpacity
} from "./url_util";

class ViewerControl {
  constructor({ map, title, urlParams }) {
    this.map = map;
    this.title = title;
    this.urlParams = urlParams;
    this.uc1description = `Hinweiskarte für Waldveränderungen (z.B. Holzschläge) 
      auf Basis von Sentinel-2-Satellitenbildern. Die Werte in der Legende 
      beschreiben die Abnahme des <a href="https://de.wikipedia.org/wiki/Normalized_Difference_Vegetation_Index"> NDVI Vegetationsindex</a> zwischen den zwei 
      Zeitpunkten. Werte näher bei -1 weisen auf stärkere Waldveränderungen (z.B. Räumungen) hin.`;
    this.uc2description = `Hinweiskarte für Sommersturmschäden auf Basis von Sentinel-2-Satellitenbildern. Die Werte in der Legende stellen die
       <strong>Abnahme des NBR (Normalized Burn Ratio) Index</strong> multipliziert mit 100 dar, 
       gemittelt pro Fläche. Die Differenzbildung erfolgt dabei jeweils aus dem Bild des <strong>ausgewählten 
       Datums</strong> und einem wolkenfreien <strong>Referenz-Composite aller verfügbaren Bilder der vorhergehenden 45 Tage.</strong> 
       Werte näher bei -100 weisen auf stärkere Schäden hin. Veränderungsflächen wurden ab einer 
       Mindestgrösse von 500 m2 ausgeschieden.`;
    this.uc3description = `Hinweiskarte für die Veränderung der Vitalität in Bezug zum Medianwert seit 2015. 
    Dargestellt sind standardisierte NDVI-Anomalien. Negative Werte deuten auf eine Abnahme der Vitalität hin, 
    positive Werte auf eine Zunahme. Jedoch kann auch Holznutzung die Ursache der Veränderung sein. 
    Je tiefer bzw. höher die Werte sind, desto wahrscheinlicher ist es, dass eine effektive Veränderung stattfand. 
    Potenzielle Fehlerquellen sind Wolken und andere atmosphärische Störungen. Insbesondere Veränderungen an den Rändern 
    der aufgrund von Wolken ausgegrauten Flächen ("nicht genug Daten") sind mit Vorsicht zu interpretieren.`;
    this.changeOverlays = [
      {
        layername: "karten-werk:ndvi_decrease_2021_2020",
        displayName: "Juni 2020 - Juni 2021",
        description: this.uc1description,
        visible: true,
        opacity: 1,
        toc: false,
        color: change_overlay_colors["ndvi_decrease_2021_2020"],
        wfs: "karten-werk:ndvi_decrease_crowd_2021_2020"
      },
      {
        layername: "karten-werk:ndvi_decrease_2020_2019",
        displayName: "Juni 2019 - Juni 2020",
        description: this.uc1description,
        visible: false,
        opacity: 1,
        toc: false,
        color: change_overlay_colors["ndvi_decrease_2020_2019"],
        wfs: "karten-werk:ndvi_decrease_crowd_2020_2019"
      },
      {
        layername: "karten-werk:ndvi_decrease_2019_2018",
        displayName: "Juni 2018 - Juni 2019",
        description: this.uc1description,
        visible: false,
        opacity: 1,
        toc: false,
        color: change_overlay_colors["ndvi_decrease_2019_2018"],
        wfs: "karten-werk:ndvi_decrease_crowd_2019_2018"
      },
      {
        layername: "karten-werk:ndvi_decrease_2018_2017",
        displayName: "Juni 2017 - Juni 2018",
        description: this.uc1description,
        visible: false,
        opacity: 1,
        toc: false,
        color: change_overlay_colors["ndvi_decrease_2018_2017"],
        wfs: "karten-werk:ndvi_decrease_crowd_2018_2017"
      },
      {
        layername: "karten-werk:ndvi_decrease_2017_2016",
        displayName: "Juni 2016 - Juni 2017",
        description: this.uc1description,
        visible: false,
        opacity: 1,
        toc: false,
        color: change_overlay_colors["ndvi_decrease_2017_2016"],
        wfs: "karten-werk:ndvi_decrease_crowd_2017_2016"
      }
    ];
    this.disorderOverlays = [
      {
        layername: "karten-werk:nbr_ch_2017",
        displayName: "Sommersturm 2017",
        intro:
          "Wählen Sie ein Datum um Veränderungsflächen der letzten <br /><strong>45 Tage</strong> zu sehen.",
        description: this.uc2description,
        visible: false,
        opacity: 1,
        toc: false
      },
      {
        layername: "karten-werk:nbr_ch_2021",
        displayName: "Sommersturm 2021 Kt. Zug",
        intro:
          "Das Sturmereignis war am 21.6.2021. Betroffen war insbes. die Region Risch ZG. <strong>Bitte wählen sie ein Datum</strong>.",
        description: this.uc2description,
        visible: false,
        opacity: 1,
        toc: false
      }
    ];
    this.verjuengungOverlays = [
      {
        layername: "karten-werk:verj_blaetterdach_groesser_12m",
        displayName: "Blätterdach (>12 m)",
        description: `Die Blätterdach-Maske zeigt Waldgebiete, in denen die Deckung der Vegetation >12 m über 33% beträgt. 
          Dies wird verwendet, um zu ermitteln ob niedrigere Vegetation unter Schirm steht oder (weitestgehend) frei.`,
        visible: false,
        opacity: 1,
        toc: false
      },
      {
        layername: "karten-werk:verj_0-2m_unter_schirm",
        displayName: "Verj. 0-2 m unter Schirm",
        description: `Gibt die modellierte Wahrscheinlichkeit an, dass hier unter dem Blätterdach Vegetation zwischen 0-2 m vorhanden ist. 
        Die Wahrscheinlichkeit basiert auf der Punktdichte der Vegetationsschicht relativ zur allgemeinen Punktdichte in dieser Zelle.
        Werte reichen von 20 - 100%, alles unter 20% ist komplett transparent.`,
        visible: true,
        opacity: 1,
        toc: false
      },
      {
        layername: "karten-werk:verj_0-2m_frei",
        displayName: "Verj. 0-2 m frei",
        description: `Gibt die modellierte Wahrscheinlichkeit an, dass hier Vegetation zwischen 0-2 m vorhanden ist. 
        Die Wahrscheinlichkeit basiert auf der Punktdichte der Vegetationsschicht relativ zur allgemeinen Punktdichte in dieser Zelle.
        Werte reichen von 20 - 100%, alles unter 20% ist komplett transparent.`,
        visible: false,
        opacity: 1,
        toc: false
      },
      {
        layername: "karten-werk:verj_0-5m_unter_schirm",
        displayName: "Verj. 0-5 m unter Schirm",
        description: `Gibt die modellierte Wahrscheinlichkeit an, dass hier unter dem Blätterdach Vegetation zwischen 0-5 m vorhanden ist. 
        Die Wahrscheinlichkeit basiert auf der Punktdichte der Vegetationsschicht relativ zur allgemeinen Punktdichte in dieser Zelle.
        Werte reichen von 20 - 100%, alles unter 20% ist komplett transparent.`,
        visible: false,
        opacity: 1,
        toc: false
      },
      {
        layername: "karten-werk:verj_0-5m_frei",
        displayName: "Verj. 0-5 m frei",
        description: `Gibt die modellierte Wahrscheinlichkeit an, dass hier Vegetation zwischen 0-5 m vorhanden ist. 
        Die Wahrscheinlichkeit basiert auf der Punktdichte der Vegetationsschicht relativ zur allgemeinen Punktdichte in dieser Zelle.
        Werte reichen von 20 - 100%, alles unter 20% ist komplett transparent.`,
        visible: false,
        opacity: 1,
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
      { year: "2021", month: this.month.slice(5, 8), layers: [] },
      { year: "2020", month: this.month.slice(5, 8), layers: [] },
      {
        year: "2019",
        month: this.month.slice(5, 8),
        layers: []
      },
      { year: "2018", month: this.month.slice(5, 8), layers: [] }
    ];
    this.disorderlayers = [];
    this.activeLayers = [];
    this.crowdsourcing = new Crowdsourcing(map);
  }

  /*
   * creates an object which can be used to create a time based wms.
   * @param {string} date - iso date format e.g. "2017-08-25".
   * @param {string} layername - namespace:name of the layer.
   * @param {boolean} visibility - visibility of the layer (on/off).
   * @param {float} opacity - layer opacity (value between 0 an 1).
   * @returns {object} layer object to use in the createWmsLayer function.
   */
  getTimeLayerObject(date, layername, visibility = true, opacity = 1) {
    const fromDate = new Date(date.substring(0, 10)).toLocaleDateString();
    return {
      layername,
      time: date || "2017-08-18",
      infoTitle: `Hinweis auf Veränderungen gemäss Bild vom ${fromDate}`,
      displayName: `Veränderung ${fromDate}`,
      description: this.uc2description,
      visible: visibility,
      opacity,
      toc: false
    };
  }

  /*
   * creates an object which can be used to vitality wms.
   * @param {object} params - function parameter object.
   * @param {number} params.year - year of the vitality layer e.g. 2018.
   * @param {object} params.month - month of the vitality layer as number and text.
   * @param {boolean} params.visibility - visibility of the layer (on/off).
   * @param {float} parmas.opacity - layer opacity (value between 0 an 1).
   * @returns {object} layer object to use in the createWmsLayer function.
   */
  getVitalityLayerObject({ year, month, visibility = true, opacity = 1 }) {
    return {
      layername: `karten-werk:ndvi_anomaly_${year}_${month.number}`,
      displayName: `NDVI Anomalien ${month.number} ${year}`,
      description: this.uc3description,
      visible: visibility,
      opacity,
      toc: false
    };
  }

  /*
   * creates the entire layer control for all the viewers.
   * @param {object} params - function parameter object.
   * @param {string} type - the type of viewer to create.
   * @returns {HTMLElement} veraenderungControlElement - a div with all the necessary children.
   */
  createControl({ type }) {
    const i18nType = type.split(" ").join("_").toLowerCase();
    const veraenderungContainer = document.createElement("div");
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
    title.classList.add("viewerControl__title-text");
    setI18nAttribute({
      element: title,
      attributeValue: `${i18nType}.viewer.title`
    });
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
        this.viewerControls = this.getDisorderControls({
          tocLayers: this.disorderOverlays,
          urlParams: this.urlParams
        });
        break;
      case "Jährliche Veränderung":
        this.viewerControls = this.createBasicControl({
          urlParams: this.urlParams,
          tocLayers: this.changeOverlays,
          layerType: "veraenderung"
        });
        // add the click event listener for crowdsourcing
        this.map.addEventListener("click", e => {
          const features = this.map.getFeaturesAtPixel(e.pixel);
          this.crowdsourcing.selectFeature({
            coordinate: e.coordinate,
            features
          });
        });
        break;
      case "Vitalität der Wälder":
        this.viewerControls = this.getVitalityControls(
          this.vitalityLayers,
          this.urlParams
        );
        break;
      case "Hinweiskarten Verjüngung":
        this.viewerControls = this.createBasicControl({
          urlParams: this.urlParams,
          tocLayers: this.verjuengungOverlays,
          layerType: "verjuengung"
        });
        break;
      default:
        return;
    }
    veraenderungContainer.appendChild(viewerTitle);
    if (this.viewerControls) {
      veraenderungContainer.appendChild(this.viewerControls);
    }
    const veraenderungControl = new Control({
      element: veraenderungContainer
    });
    return veraenderungControl;
  }

  /*
   * create a basic layer control.
   * @param {object} params - function parameter object.
   * @param {object} params.urlParams - url parameters.
   * @param {array} params.tocLayers - layers which must be available in the toc.
   * @param {string} params.layertype - "veraenderung", ""
   * @returns {htmlElement} - a div element with all the controls for the viewer.
   */
  createBasicControl({ urlParams, tocLayers, layerType } = {}) {
    if (!tocLayers) {
      return;
    }
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const dropdown = this.createLayerDropdown({ tocLayers });
    controls.appendChild(dropdown);
    const layers = document.createElement("div");
    layers.classList.add("layers");
    controls.appendChild(layers);
    // check if there are layers in the url params
    if (urlParams.layers) {
      this.addLayersFromUrlParams({
        urlParams,
        layerType,
        domContainer: layers
      });
    }
    if (this.activeLayers.length === 0) {
      // if no layers in the urlParams, add some specific layers.
      if (layerType === "verjuengung") {
        // 0-5m unter schirm
        this.addLayer({
          layer: this.verjuengungOverlays[3],
          domContainer: layers
        });
        // 0-2m unter schirm
        this.addLayer({
          layer: this.verjuengungOverlays[1],
          domContainer: layers
        });
        // blaetterdach
        this.addLayer({
          layer: this.verjuengungOverlays[0],
          domContainer: layers
        });
      }
      if (layerType === "veraenderung") {
        // the latest available year
        this.addLayer({
          layer: this.changeOverlays[0],
          domContainer: layers
        });
      }
    }
    return controls;
  }

  /*
   * add layers from url parameters to the map
   */
  addLayersFromUrlParams({ urlParams, layerType, domContainer } = {}) {
    const layersToAdd = this.getLayersFromUrlParams({
      urlParams,
      layerType
    });
    if (layersToAdd.length > 0) {
      for (var i = layersToAdd.length; i >= 0; i--) {
        this.addLayer({ layer: layersToAdd[i], domContainer });
      }
    }
  }

  /*
   * get layer objects from url parameters
   * @param {object} urlParams - url parameter object
   * @returns {array} layersToAdd - layer objects which can be added to the map.
   */
  getLayersFromUrlParams({ urlParams, layerType } = {}) {
    const layerArr = urlParams.layers.split(",");
    const visibilities = urlParams.visibility
      ? urlParams.visibility.split(",")
      : [];
    const opacities = urlParams.opacity ? urlParams.opacity.split(",") : [];
    const times = urlParams.time ? urlParams.time.split(",") : [];
    if (layerArr.length > 0) {
      const layersToAdd = [];
      // get the right veraenderung layer and add it to the viewer
      layerArr.forEach((layername, index) => {
        const splitted = layername.split("_");
        const year = splitted[2];
        const month = splitted[3];
        let layers = [];
        switch (layerType) {
          case "veraenderung":
          case "verjuengung":
            if (layerType === "veraenderung") {
              layers = this.changeOverlays;
            }
            if (layerType === "verjuengung") {
              layers = this.verjuengungOverlays;
            }
            for (var i = 0; i < layers.length; i++) {
              if (layers[i].layername === layername) {
                layers[i].visible = this.getVisibility(visibilities, index);
                layers[i].opacity = this.getOpacity(opacities, index);
                layersToAdd.push(layers[i]);
              }
            }
            break;
          case "vitalitaet":
            for (var y = 0; y < this.vitalityLayers.length; y++) {
              if (
                this.vitalityLayers[y].year === year &&
                this.vitalityLayers[y].layers.length > 0
              ) {
                this.vitalityLayers[y].layers.forEach(layer => {
                  const layerMonth = layer.layername.split("_")[3];
                  if (month === layerMonth) {
                    layer.visible = this.getVisibility(visibilities, index);
                    layer.opacity = this.getOpacity(opacities, index);
                    layersToAdd.push(layer);
                  }
                });
              }
            }
            break;
          case "stoerungen":
            if (Array.isArray(times) && times.length > 0) {
              for (var x = 0; x < this.disorderlayers.length; x++) {
                if (
                  layername === this.disorderlayers[x].layername &&
                  times[index] === this.disorderlayers[x].time.substring(0, 10)
                ) {
                  this.disorderlayers[x].visible = this.getVisibility(
                    visibilities,
                    index
                  );
                  this.disorderlayers[x].opacity = this.getOpacity(
                    opacities,
                    index
                  );
                  layersToAdd.push(this.disorderlayers[x]);
                }
              }
            }
            break;
          default:
            return layersToAdd;
        }
      });
      return layersToAdd;
    } else {
      return [];
    }
  }
  /*
   * used to get a usable visibility value for a layer
   * which is loaded via url.
   * @param {array} visibilities - from url param.
   * @param {number} index - index in visibilities to check.
   */
  getVisibility(visibilities, index) {
    if (!visibilities || !Array.isArray(visibilities) || index < 0) {
      return true;
    }
    return visibilities[index] === "false" ? false : true;
  }

  /*
   * used to get a usable opacity value for a layer
   * which is loaded via url.
   * @param {array} opacities - from url param.
   * @param {number} index - index in opacities to check.
   */
  getOpacity(opacities, index) {
    if (!opacities || !Array.isArray(opacities) || index < 0) {
      return 1;
    }
    return opacities[index] ? parseFloat(opacities[index]) : 1;
  }

  /*
   * create the controls for the "Vitalität der Wälder" viewer.
   * @param {array} years - the years to display in the dropdown [{displayName:2019},...].
   * @returns {htmlElement} - a div element with all the controls for the viewer.
   */
  getVitalityControls(years, urlParams) {
    const yearObjects = [];
    years.forEach(yearObj => yearObjects.push({ displayName: yearObj.year }));
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const monthChips = document.createElement("div");
    monthChips.classList.add("monthchips");
    const title = document.createElement("div");
    title.classList.add("viewerControl__yearinfo");
    title.innerText = "Monate:";
    monthChips.appendChild(title);
    const chipsetEl = document.createElement("div");
    chipsetEl.classList.add("mdc-chip-set", "mdc-chip-set--filter");
    monthChips.appendChild(chipsetEl);
    const dropdown = this.createVitalityDropdown(yearObjects, chipsetEl);
    controls.appendChild(dropdown);
    const layers = document.createElement("div");
    layers.classList.add("layers");
    controls.appendChild(monthChips);
    controls.appendChild(layers);
    // check if there are layers in the url params
    if (urlParams.layers) {
      this.addLayersFromUrlParams({
        urlParams,
        layerType: "vitalitaet",
        domContainer: layers
      });
    }
    return controls;
  }

  /*
   * removes layers from the ol map.
   * @param {array} layers - array of layer objects.
   */
  removeMapOverlays(layers) {
    layers.forEach(layer => {
      this.removeLayer(layer);
    });
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
    setI18nAttribute({
      element: mdcSelectLabel,
      attributeValue: "viewer.addlayer"
    });
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
   * @param {object} params - function parameter object.
   * @param {array} params.tocLayers - layer objects which must be available in the dropdown.
   * @param {function} params.callback - function to call when select menu changes
   * @returns {htmlElement} - dropdown menu with layers to choose.
   */
  createLayerDropdown({ tocLayers, callback }) {
    const { dropdownContainer, mdcSelect } = this.createMDCDropdown(
      "Layer hinzufügen"
    );
    if (!callback) {
      callback = event => {
        const layer = tocLayers.filter(
          overlay => overlay.displayName === event.detail.value
        )[0];
        if (layer.toc === true) {
          console.log("layer allready in toc");
          return;
        }
        layer.visible = true;
        layer.toc = true;
        this.addLayer({
          layer,
          domContainer: document.querySelector(".layers")
        });
      };
    }
    this.createSelectMenu({
      items: tocLayers,
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
  createVitalityDropdown(years, chipsetEl) {
    const { dropdownContainer, mdcSelect } = this.createMDCDropdown(
      "Jahr wählen"
    );
    // create all potential layers
    this.vitalityLayers.forEach(element => {
      element.month.forEach(month => {
        const layer = this.getVitalityLayerObject({
          year: element.year,
          month
        });
        layer.chip = this.createChip({ label: month.text, layer });
        element.layers.push(layer);
      });
    });
    const callback = e => {
      chipsetEl.innerHTML = "";
      const year = e.detail.value;
      const selectedYear = this.vitalityLayers.filter(
        layer => layer.year.toString() === year.toString()
      )[0];
      selectedYear.layers.forEach(layer => chipsetEl.appendChild(layer.chip));
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
      const i18n = layer.displayName.split(" ").join("").toLowerCase();
      const li = document.createElement("li");
      li.classList.add("mdc-list-item");
      li.setAttribute("data-value", layer.displayName);
      li.innerHTML = layer.displayName;
      setI18nAttribute({ element: li, attributeValue: `viewer.layer.${i18n}` });
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
    this.activeLayers.push(layer);
    if (!layer.wmsLayer) {
      layer.wmsLayer = this.createWmsLayer(layer);
    }
    if (layer.wfs) {
      layer.wfsLayer = this.createWfsLayer(layer);
    }
    layer.wmsLayer.setOpacity(layer.opacity);
    layer.wmsLayer.setVisible(layer.visible);
    this.map.addLayer(layer.wmsLayer);
    // add the wfs on top of the wms
    if (layer.wfsLayer) {
      this.map.addLayer(layer.wfsLayer);
    }
    layer.domElement = this.createLayerControl(layer);
    domContainer.prepend(layer.domElement);
    if (layer.chip) {
      layer.chip.classList.add("chip--selected");
    }
    addLayerToUrl({ ...layer, opacity: layer.wmsLayer.getOpacity() });
    return layer;
  }

  /*
   * remove a layer from the map and the toc.
   * @param {object} layer - layer object with neccessary params like wmsLayer and domElement.
   * @returns {object} layer - the layer object of the removed layer.
   */
  removeLayer(layer) {
    layer.toc = false;
    this.map.removeLayer(layer.wmsLayer);
    if (layer.wfsLayer) {
      this.map.removeLayer(layer.wfsLayer);
    }
    const layers = document.querySelector(".layers");
    if (layers.contains(layer.domElement)) {
      layers.removeChild(layer.domElement);
    }
    this.activeLayers.splice(this.activeLayers.indexOf(layer), 1);
    if (layer.chip) {
      layer.chip.classList.remove("chip--selected");
    }
    removeLayerFromUrl(layer);
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
    const layerTopRightBlock = document.createElement("div");
    layerTopRightBlock.style.display = "flex";
    layerTopRightBlock.style.alignItems = "center";
    layerTopRightBlock.style.justifyContent = "end";
    layerTopRightBlock.style.flexGrow = 1;
    if (layer.color) {
      layerTopRightBlock.appendChild(this.getLayercolor(layer));
    }
    layerTopRightBlock.appendChild(this.getLayerRemoveButton(layer));
    layerControl.appendChild(layerTopRightBlock);
    layerControl.appendChild(this.getSlider(layer));
    if (this.title === "Natürliche Störungen") {
      layerControl.appendChild(this.getSentinelLink(layer));
    }
    layerControl.appendChild(this.getLayerInfoButton(layer));
    return layerControl;
  }

  /*
   * create the controls for the "Natürliche Störungen" viewer.
   * @param {object} function parameter object.
   * @param {array} params.tocLayers - layers to add to the dropdown menu. (this.disorderOverlays).
   * @param {object} params.urlParams - url parameter object.
   * @returns {htmlElement} - all the controls for the disorder viewer.
   */
  getDisorderControls({ tocLayers, urlParams }) {
    const controls = document.createElement("div");
    controls.classList.add("viewerControl__controls");
    const disorderLayerControls = document.createElement("section");
    // the function to call when the dropdown changes.
    const callback = e => {
      this.removeMapOverlays(this.activeLayers);
      const disorderOverlay = this.disorderOverlays[e.detail.index];
      this.getDisorderLayerControls({
        urlParams: getQueryParams(), //these must be the current params!
        disorderOverlay,
        disorderLayerControls
      });
    };
    // dropdown for case selection
    const dropdown = this.createLayerDropdown({
      tocLayers,
      callback
    });
    controls.appendChild(dropdown);
    controls.appendChild(disorderLayerControls);
    let disorderOverlay = this.disorderOverlays[0];
    // add the layer from the url param if it exists
    // else, use the first one from the disorderoverlays.
    if (urlParams.layers) {
      disorderOverlay = this.disorderOverlays.filter(
        element => element.layername === urlParams.layers
      )[0];
    }
    this.getDisorderLayerControls({
      urlParams,
      disorderOverlay,
      disorderLayerControls
    });
    return controls;
  }

  /*
   * create the layer chips for the disorder layers.
   * @param {object} params - function parameter object.
   * @param {object} params.urlParams - url parameters.
   * @param {object} params.disorderOverlay - element from this.disorderOverlays.
   * @param {domElement} params.disorderLayerControls - container to append the chips etc.
   * @returns {domElement} disorderLayerControls - container filled with content (chips etc.).
   */
  getDisorderLayerControls({
    urlParams,
    disorderOverlay,
    disorderLayerControls
  }) {
    //clear the element from previous content.
    disorderLayerControls.innerHTML = "";
    this.disorderlayers = [];

    const intro = document.createElement("div");
    intro.classList.add("viewerControl__helpertext");
    intro.innerHTML = `<strong>${disorderOverlay.displayName}</strong> <br /><br /> ${disorderOverlay.intro}`;
    disorderLayerControls.appendChild(intro);
    const yearInfo = document.createElement("div");
    yearInfo.classList.add("viewerControl__yearinfo");
    disorderLayerControls.appendChild(yearInfo);
    const dateChips = document.createElement("div");
    dateChips.classList.add("datechips");
    const chipsetEl = document.createElement("div");
    chipsetEl.classList.add("mdc-chip-set", "mdc-chip-set--filter");
    const layers = document.createElement("div");
    layers.classList.add("layers");
    disorderLayerControls.appendChild(chipsetEl);
    disorderLayerControls.appendChild(layers);
    this.getDimensions(disorderOverlay.layername).then(response => {
      const year = response[0].split("-")[0];
      yearInfo.innerHTML = `Jahr ${year}`;
      response.forEach(date => {
        const layer = this.getTimeLayerObject(date, disorderOverlay.layername);
        const printDate = date.substring(0, 10);
        layer.chip = this.createChip({
          label: this.formatDateString(printDate),
          layer,
          singleLayer: true
        });
        chipsetEl.appendChild(layer.chip);
        // we need this to add the layer when it was in the url.
        this.disorderlayers.push(layer);
      });
      if (urlParams.layers) {
        this.addLayersFromUrlParams({
          urlParams,
          layerType: "stoerungen",
          domContainer: layers
        });
      }
    });
    return disorderLayerControls;
  }

  /*
   * unselect all chips, except the one with the id from the function parameter.
   * @param {object} params - function parameter object.
   * @param {MDLChipset} params.chipset - the set with all the chips.
   * @param {string} params.id - the id of the string that should be selected.
   * @returns {MDLChipset} - chipset with updated chips.
   */
  unselectChips() {
    const chips = document.getElementsByClassName("chip");
    for (var i = 0; i < chips.length; i++) {
      chips.item(i).classList.remove("chip--selected");
    }
    return chips;
  }

  /*
   * get all the available time dimensions for the nbr_change layer.
   * @param {string} layername - name of the layer to query the dimensions.
   * @returns {promise} - promise with all the available time strings.
   */
  getDimensions(layername) {
    const url = "https://geoserver.karten-werk.ch/wms?request=getCapabilities";
    const parser = new WMSCapabilities();
    return fetch(url)
      .then(response => response.text())
      .then(text => {
        const result = parser.read(text);
        const layers = result.Capability.Layer.Layer;
        const nbr = layers.filter(layer => layer.Name === layername)[0];
        const dimensions = nbr.Dimension[0].values.split(",");
        return dimensions;
      });
  }

  /*
   * create a chip for the "Vitalität der Wälder" viewer.
   * @param {number} year - 2018, 2019....
   * @param {object} month - {monthNumber:"06-07":monthText:"Jun/Jul"}.
   * @returns {htmlElement} chip.
   */
  createChip({ label, layer, singleLayer = false } = {}) {
    label = label ? label : "unbekannt";
    const chip = document.createElement("div");
    chip.classList.add("chip");
    const chipContent = document.createElement("span");
    chipContent.classList.add("chip__content");
    chipContent.innerHTML = label;
    chip.appendChild(chipContent);
    chip.addEventListener("click", () => {
      const domContainer = document.querySelector(".layers");
      if (singleLayer) {
        this.removeMapOverlays(this.activeLayers);
      }
      if (layer.toc === true) {
        this.removeLayer(layer);
      } else {
        this.addLayer({
          layer,
          domContainer
        });
      }
    });
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
   * creates a ol/VectorLayer for a geoserver WFS.
   * @param {object} overlay - overlay object like stored in the model.
   * @returns {object} VectorLayer - ol.Layer.Vector instance.
   */
  createWfsLayer(overlay) {
    const host = "https://geoserver.karten-werk.ch/wfs?";
    const vectorSource = new VectorSource({
      format: new GeoJSON(),
      url: function (extent) {
        return (
          host +
          "wfs?service=WFS&" +
          "version=1.1.0&request=GetFeature&typename=" +
          overlay.wfs +
          "&outputFormat=application/json&srsname=EPSG:3857&" +
          "bbox=" +
          extent.join(",") +
          ",EPSG:3857"
        );
      },
      strategy: bboxStrategy
    });
    const wfsLayer = new VectorLayer({
      source: vectorSource,
      style: this.crowdsourcing.wfsStyle
    });
    return wfsLayer;
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
      title.innerHTML = overlay.infoTitle
        ? overlay.infoTitle
        : overlay.displayName;
      const description = document.createElement("div");
      description.innerHTML = getLayerInfo(overlay);
      content.appendChild(title);
      content.appendChild(description);
      openSidebar({ content });
    });
    return layerInfo;
  }

  getLayercolor(layer) {
    const color = document.createElement("div");
    color.title = `Layerfarbe: ${layer.color.name}`;
    color.style.backgroundColor = layer.color.hex;
    color.style.borderRadius = "6px";
    color.style.height = "12px";
    color.style.width = "20px";
    color.style.marginRight = "8px";
    return color;
  }

  getLayerRemoveButton(layer) {
    const removeLayer = document.createElement("button");
    removeLayer.title = "Layer entfernen";
    removeLayer.classList.add(
      "layer-button",
      "mdc-icon-button",
      "material-icons"
    );
    removeLayer.innerHTML = "remove_circle";
    removeLayer.addEventListener("click", () => {
      this.removeLayer(layer);
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
        `maxcc=100&` +
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
    const i18n = overlay.displayName.split(" ").join("").toLowerCase();
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
        if (overlay.wfsLayer) {
          overlay.wfsLayer.setVisible(e.target.checked);
        }
        overlay.visible = e.target.checked;
        input.setAttribute("aria-checked", e.target.checked.toString());
        updateUrlVisibilityOpacity({
          ...overlay,
          opacity: overlay.wmsLayer.getOpacity()
        });
      });
    }
    label.setAttribute("for", `${overlay.layername}_switch`);
    setI18nAttribute({
      element: label,
      attributeValue: `viewer.layer.${i18n}`
    });
    label.innerHTML = `${overlay.displayName}`;
    label.style.padding = "0 0 0 12px";
    label.style.minWidth = "60%";
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
   * @param {object} layer - layer object.
   * @returns {Div Element} sliderContainer - transparency slider.
   */
  getSlider(layer) {
    const { wmsLayer, wfsLayer } = layer;
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
    slider.setAttribute("aria-valuenow", `${layer.opacity * 100}`);
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
    let opacity = 1;
    window.requestAnimationFrame(() => {
      const mdcslider = new MDCSlider(slider);
      mdcslider.listen("MDCSlider:input", e => {
        opacity = parseFloat(e.target.getAttribute("aria-valuenow") / 100);
        wmsLayer.setOpacity(opacity);
        if (wfsLayer) {
          wfsLayer.setOpacity(opacity);
        }
        layer.opacity = opacity;
      });
      // wait for the change to be commited before
      // updating the url.
      mdcslider.listen("MDCSlider:change", () => {
        updateUrlVisibilityOpacity({
          ...layer,
          opacity
        });
      });
    });

    return sliderContainer;
  }
}
export default ViewerControl;
