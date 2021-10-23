import Feature from "ol/Feature";
import Geolocation from "ol/Geolocation";
import { Point, LineString } from "ol/geom";
import { Vector as VectorLayer } from "ol/layer";
import { Vector as VectorSource } from "ol/source";
import { Circle as CircleStyle, Fill, Stroke, Style, Icon } from "ol/style";
import { containsXY } from "ol/extent";
import { convertPointCoordinates } from "./projectionUtil";
import { dialog } from "./init";
import { dialogTitle, dialogContent } from "./main_util";
const gpsIcon = new URL("../img/gps.svg", import.meta.url);
const gpsButton = new URL("../img/gps_icon.jpg", import.meta.url);
const gpsArrow = new URL("../img/gps_arrow_icon.svg", import.meta.url);
const gpsArrowIcon = document.createElement("img");
gpsArrowIcon.src = gpsArrow;
gpsArrowIcon.alt = "gps arrow icon";
gpsArrowIcon.style.width = "20px";
gpsArrowIcon.style.height = "20px";
const positionStroke = new Stroke({
  color: "#ffffff",
  width: 1.5
});
const positionFill = new Fill({
  color: "red"
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
const positionHeadingStyle = new Style({
  image: new Icon({
    crossOrigin: "anonymous",
    img: gpsArrowIcon,
    imgSize: [20, 20]
  })
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

/*
 * linestring to store different geolocation positions.
 * this linestring is time aware. the z dimension is used
 * to store the rotation (heading)
 */
const positions = new LineString([], "XYZM");

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
          `Es gab einen Fehler bei der GPS Positionierung. Error message: ${error.message}\nBitte stellen sie sicher, dass sie via https:// und nicht nur via http:// verbunden sind. (https://waldmonitoring.ch/)`
        );
        this.disableTracking(this.positionElement);
      });

      this.geolocation.on("change:accuracyGeometry", () => {
        accuracyFeature.setGeometry(this.geolocation.getAccuracyGeometry());
        const accuracyArea = parseInt(
          this.geolocation.getAccuracyGeometry().getArea()
        );
        const radius = parseInt(Math.sqrt(accuracyArea / Math.PI));
        if (radius > 100) {
          dialogTitle.innerHTML = "Warnung GPS Genauigkeit";
          dialogContent.innerHTML = `Die GPS Positionierung ist momentan nicht sehr genau. (<strong>Radius von ${radius}m</strong>) <br />
        Dies kann vorkommen, wenn die Positionierung z.B. auf einem Desktop Computer verwendet wird.
        Um das GPS zu deaktivieren, klicken Sie auf diesen Button oben rechts. <img src="${gpsButton}" alt="gps button" style="vertical-align:middle;" />`;
          dialog.open();
        } else {
          dialog.close();
        }
      });

      this.geolocation.on("change:position", () => {
        const height = this.geolocation.getAltitude();
        const position = this.geolocation.getPosition();
        const heading = this.geolocation.getHeading() || 0;
        const speed = this.geolocation.getSpeed() || 0;
        const m = Date.now();
        const lv95Coords = convertPointCoordinates({
          sourceProj: "EPSG:3857",
          destProj: "EPSG:2056",
          position
        });
        this.setAttribution(lv95Coords, height);
        this.addPosition({ position, heading, m, speed });
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

  /*
   * update the attribution with the newest gps measurements.
   * @param {array} lv95Coords - coordinates in lv95 projection.
   * @param {number} height - the height in m.ü.m.
   */
  setAttribution(lv95Coords, height) {
    const gpsAttribution = `<br />GPS (LV95): ${Math.round(
      lv95Coords[0]
    ).toLocaleString("de-CH")}, ${Math.round(lv95Coords[1]).toLocaleString(
      "de-CH"
    )} | Höhe (m.ü.M): ${height ? Math.round(height) : "unbekannt"}`;
    this.source.setAttributions(gpsAttribution);
  }

  /*
   * does all the manipulation on the gps marker icon.
   * @param {object} params - function parameter object.
   * @param {array} params.position - result of geolocation.getPosition()
   * @param {number} params.heading - result of geolocation.getHeading() (radians clowise from North)
   * @param {date} params.m - A time value from date.now()
   * @param {number} params.speed - result from geolocation.getSpeed() (m/s)
   */
  addPosition({ position, heading, m, speed }) {
    // x coordinate
    const x = position[0];
    // y coordinate
    const y = position[1];
    // get all coordinate objects inside the lineString object.
    const fCoords = positions.getCoordinates();
    // the last the last one from the coordinate objects.
    const previous = fCoords[fCoords.length - 1];
    // get the last heading value
    const prevHeading = previous && previous[2];
    if (prevHeading) {
      // get the difference between the last and the previous heading.
      let headingDiff = heading - this.mod(prevHeading);
      // force the rotation change to be less than 180°
      // here is the magic !!!
      if (Math.abs(headingDiff) > Math.PI) {
        const sign = headingDiff >= 0 ? 1 : -1;
        headingDiff = -sign * (2 * Math.PI - Math.abs(headingDiff));
      }
      heading = prevHeading + headingDiff;
    }
    // add the latest calculations to coordinates
    positions.appendCoordinate([x, y, heading, m]);

    // only keep the 20 last coordinates
    positions.setCoordinates(positions.getCoordinates().slice(-20));

    // set the gps icon based on wether we have a heading and speed or not.
    if (heading && speed) {
      positionHeadingStyle.getImage().setRotation(heading);
      positionFeature.setStyle(positionHeadingStyle);
    } else {
      positionFeature.setStyle(positionStyle);
    }
    positionFeature.setGeometry(position ? new Point(position) : null);
    this.centerViewOnGps(x, y, this.map);
  }

  /*
   * center the map on the geolocation marker if it the latter is outside the map extent
   * @param {number} x - the x coordinate.
   * @param {number} y - the y coordinate.
   * @param {object} map - ol/map instance.
   */
  centerViewOnGps(x, y, map) {
    if (!x || !y || !map) return;
    const mapExtent = map.getView().calculateExtent(this.map.getSize());
    if (containsXY(mapExtent, x, y)) {
      return true;
    } else {
      map.getView().setCenter([x, y]);
    }
  }

  // modulo for negative values
  mod(n) {
    return ((n % (2 * Math.PI)) + 2 * Math.PI) % (2 * Math.PI);
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
