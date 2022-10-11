import { Control } from "ol/control";
import { vegetationBasemap } from "./basemap_util";
import { updateUrl, removeParam } from "./url_util";
import {
  openSidebar,
  sidebar,
  closeSidebar,
  clearSidebar,
  GEO_ADMIN_WMS_INFO_URL,
  setI18nAttribute
} from "./main_util";
const vegetationImage = new URL(
  "../img/basemapVegetation.jpg",
  import.meta.url
);
const infoIcon = new URL("../img/info_black_24dp.svg", import.meta.url);
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
    const vhmInfo = document.createElement("img");
    vhmInfo.src = infoIcon;
    vhmInfo.alt = "layer infos";
    vhmInfo.className = "vhmControl__info";
    vhmInfo.addEventListener("click", e => {
      e.stopPropagation();
      if (sidebar.dataset.open === "false") {
        // open the sidebar for an immediate user experience
        const waiting = document.createElement("div");
        waiting.classList.add("vhmControl__waiting");
        waiting.style.paddingTop = "32px";
        waiting.innerHTML = "Loading...<br /><br /> Bitte einen Moment Geduld.";
        openSidebar({ content: waiting });
        // populate the sidebar with content
        this.getVHMInfoContent().then(content => {
          clearSidebar();
          window.translator.run();
          openSidebar({ content });
        });
      } else {
        closeSidebar();
      }
    });
    const buttonTitle = document.createElement("span");
    buttonTitle.textContent = "VHM";
    vhmTitle.appendChild(buttonTitle);
    vhmTitle.appendChild(vhmInfo);
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

  async getVHMInfoContent() {
    const info = document.createElement("div");
    const title = document.createElement("h3");
    setI18nAttribute({ element: title, attributeValue: "viewer.layer.vhm" });
    try {
      const response = await fetch(
        `${GEO_ADMIN_WMS_INFO_URL}layername=ch.bafu.landesforstinventar-vegetationshoehenmodell`
      );
      const json = await response.json();
      title.textContent = json.layer.title[0];
      info.appendChild(title);
      const legendUrl =
        json?.layer?.style[0]?.LegendURL[0]?.OnlineResource[0]?.$[
          "xlink:href"
        ] ||
        "https://api.geo.admin.ch/static/images/legends/ch.bafu.landesforstinventar-vegetationshoehenmodell_de.png";

      const legend = document.createElement("h4");
      setI18nAttribute({ element: legend, attributeValue: "sidebar.legende" });
      legend.textContent = "Legende:";
      const legendImage = document.createElement("img");
      legendImage.src = legendUrl;
      legendImage.alt = "vhm legende";
      info.appendChild(legend);
      info.appendChild(legendImage);
      const description = document.createElement("h4");
      setI18nAttribute({
        element: description,
        attributeValue: "sidebar.beschreibung"
      });
      description.textContent = "Beschreibung:";
      info.appendChild(description);
      const abstract = document.createElement("div");
      abstract.innerText = json?.layer?.abstract[0];
      info.appendChild(abstract);
      return info;
    } catch (error) {
      const errorContent = document.createElement("div");
      errorContent.innerHTML = `Es gab einen Fehler beim Laden der Layer Infos: <hr /> ${error} <hr /> Bitte versuchen sie es später nochmals.`;
      info.appendChild(errorContent);
      return info;
    }
  }
}
export default VHMControl;
