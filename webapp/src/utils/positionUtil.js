import Feature from "ol/Feature";
import Geolocation from "ol/Geolocation";
import Point from "ol/geom/Point";
import { Vector as VectorLayer } from "ol/layer";
import { Vector as VectorSource } from "ol/source";
import { Circle as CircleStyle, Fill, Stroke, Style } from "ol/style";
import { convertPointCoordinates } from "./projectionUtil";
import gpsIcon from "url:../img/gps.svg";
const positionStroke = new Stroke({
  color: "#ffffff",
  width: 1.5
});
const positionFill = new Fill({
  color: "red" //"#f9aa33"
});
const positionStyle = new Style({
  image: new CircleStyle({
    radius: 5,
    fill: positionFill,
    stroke: positionStroke
  }),
  stroke: positionStroke,
  fill: positionFill
});
const accuracyStyle = new Style({
  stroke: new Stroke({
    color: "red", //"#f9aa33",
    width: 1
  }),
  fill: new Fill({
    color: "rgba(255,255,255,0.5)"
  })
});
const accuracyFeature = new Feature();
const positionFeature = new Feature();
positionFeature.setStyle(positionStyle);
positionFeature.setId("gpsPosition");
accuracyFeature.setStyle(accuracyStyle);
accuracyFeature.setId("gpsAccuracy");
accuracyFeature.setProperties({
  _style: { fill: "#ffffff", stroke: { color: "#fbc02d" } }
});

export default class GpsPosition {
  constructor(map) {
    if (!GpsPosition.instance) {
      this.map = map;
      this.positionElement = document.createElement("div");
      this.source = new VectorSource({
        features: [accuracyFeature, positionFeature]
      });
      this.positionLayer = new VectorLayer({
        zIndex: 1000,
        source: this.source
      });
      this.positionLayer.name = "gps";
      this.geolocation = new Geolocation({
        // enableHighAccuracy must be set to true to have the heading value.
        trackingOptions: {
          enableHighAccuracy: true
        }
      });

      this.geolocation.on("error", error => {
        alert(
          `Es gab einen Fehler bei der GPS Positionierung. Error message: ${error.message}`
        );
        this.disableTracking(this.positionElement);
      });

      this.geolocation.on("change:accuracyGeometry", () => {
        accuracyFeature.setGeometry(this.geolocation.getAccuracyGeometry());
      });

      this.geolocation.on("change:position", () => {
        const height = this.geolocation.getAltitude();
        const coordinates = this.geolocation.getPosition();
        const lv95Coords = convertPointCoordinates({
          sourceProj: "EPSG:3857",
          destProj: "EPSG:2056",
          coordinates
        });
        const gpsAttribution = `<br />GPS (LV95): ${Math.round(
          lv95Coords[0]
        ).toLocaleString("de-CH")}, ${Math.round(lv95Coords[1]).toLocaleString(
          "de-CH"
        )} | Höhe (m.ü.M): ${height ? Math.round(height) : "unbekannt"}`;
        this.source.setAttributions(gpsAttribution);
        positionFeature.setGeometry(
          coordinates ? new Point(coordinates) : null
        );
      });
      Object.freeze(this); // make it unchangeable
      GpsPosition.instance = this;
    }
    /*
     * from the constructor we return the first ever created
     * instance of this class. (Singleton pattern)
     */
    return GpsPosition.instance;
  }
  /* creates the position/gps element which can
   * be used as a control on the map
   * @param {object} map - ol/map instance
   * @returns {htmlElement} - the position/gps element.
   */
  getPositionElement() {
    let active = false;
    this.positionElement.classList.add("ol-unselectable", "ol-control");
    this.positionElement.style.backgroundColor = "#f9aa33";
    this.positionElement.style.boxShadow =
      "0.1px 1px 1.5px 0 rgba(112,112,112,0.95)";
    this.positionElement.style.top = "9.5em";
    this.positionElement.style.right = "1em";
    this.positionElement.style.width = "40px";
    this.positionElement.style.height = "40px";
    this.positionElement.style.borderRadius = "20px";
    this.positionElement.style.display = "flex";
    this.positionElement.style.justifyContent = "center";
    this.positionElement.style.alignItems = "center";
    this.positionElement.style.cursor = "pointer";
    this.positionElement.style.transition = "background-color 0.2s ease-in-out";
    const icon = document.createElement("img");
    icon.src = gpsIcon;
    icon.style.width = "23px";
    icon.style.height = "23px";
    this.positionElement.appendChild(icon);
    this.positionElement.addEventListener("mouseenter", () => {
      this.positionElement.style.opacity = "0.9";
    });
    this.positionElement.addEventListener("mouseleave", () => {
      this.positionElement.style.opacity = "1";
    });
    this.positionElement.addEventListener("click", () => {
      active = !active;
      if (active) {
        this.positionElement.classList.add("animatePositionButton");
        this.geolocation.setProjection(this.map.getView().getProjection());
        this.geolocation.setTracking(true);
        this.map.addLayer(this.positionLayer);
        this.geolocation.once("change:position", () => {
          this.centerOnPosition(this.geolocation.getPosition());
        });
      } else {
        this.disableTracking(this.positionElement);
      }
    });
    return this.positionElement;
  }

  centerOnPosition(position) {
    this.map.getView().animate({ center: position, zoom: 17, duration: 1000 });
  }

  disableTracking(positionElement) {
    positionElement.classList.remove("animatePositionButton");
    this.geolocation.setTracking(false);
    this.map.removeLayer(this.positionLayer);
  }
}
