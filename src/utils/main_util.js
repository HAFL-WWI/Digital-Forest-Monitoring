import { Circle as CircleStyle, Fill, Stroke, Style } from "ol/style";
import VectorLayer from "ol/layer/Vector";
import VectorSource from "ol/source/Vector";
import GeoJSON from "ol/format/GeoJSON";
import { getCenter } from "ol/extent";
const appBarTitle = document.getElementsByClassName("top-app-bar__title")[0];
export const sidebar = document.querySelector(".sidebar");
const sidebarContent = document.querySelector(".sidebar__content");
/*
 * changes the top appbar title.
 * @param {string} title - the new title to display.
 * @returns {boolean} - true if title changed successfully, false otherwise.
 */
export const setTitle = title => {
  if (!title) {
    return false;
  }
  appBarTitle.innerHTML = title;
  return true;
};

/*
 * calculates the title based on the window.width.
 * @returns {string} title - title to use based on the current window.width.
 */
export const getTitle = () => {
  const width = window.innerWidth;
  const title =
    width <= 550
      ? "Waldmonitoring"
      : "Waldmonitoring mit Sentinel Satellitenbildern";
  return title;
};

/*
 * hide the appBar title
 */
export const hideTitle = () => {
  appBarTitle.style.display = "none";
};
/*
 * show the appBar title
 */
export const showTitle = () => {
  appBarTitle.style.display = "block";
};

export const impressum = {
  tite: "IMRESSUM",
  content: `Dies ist ein Forschungsprojekt der BFH-HAFL im Auftrag bzw. mit
Unterstützung des BAFU. Im Rahmen dieses Projektes sollen
vorhandene, möglichst schweizweit flächendeckende und frei
verfügbare Fernerkundungsdaten für konkrete Use-Cases und mit einem
klaren Mehrwert für die Praxis eingesetzt werden. Das Hauptziel
dieses Projektes ist die Implementierung von Kartenviewern sowie
Geodiensten für mindestens 3 konkrete Use-Cases.
<br /></br />
Ansprechperson BFH-HAFL: Dominique Weber (+41 31 910 29 32,
<a href="mailto:dominique.weber@bfh.ch">dominique.weber@bfh.ch</a>)`
};

export const getLayerInfo = overlay => {
  return `<div>
  <h4>Legende:</h4>
  <img src="https://geoserver.karten-werk.ch//wms?REQUEST=GetLegendGraphic&VERSION=1.0.0&FORMAT=image/png&height=15&LAYER=${overlay.layername}&legend_options=forceLabels:on" />
  <h4>Beschreibung:</h4>
  <section>${overlay.description}</section>
  </div>`;
};

export const dialogTitle = document.querySelector("#dialog-title");
export const dialogContent = document.querySelector("#dialog-content");
export const searchResults = document.querySelector(".autocomplete");

/*
 *  set the position of the search result box below the search input.
 */
export const positionSearchResultContainer = () => {
  const searchInput = document.querySelector(".mdc-text-field");
  const searchMetrics = searchInput.getBoundingClientRect();
  searchResults.style.left = `${searchMetrics.left}px`;
  searchResults.style.width = `${searchMetrics.width}px`;
};

/*
 * debounce function for the places search
 * Returns a function, that, as long as it continues to be invoked, will not
 * be triggered. The function will be called after it stops being called for
 * N milliseconds. If `immediate` is passed, trigger the function on the
 * leading edge, instead of the trailing.
 * credits:https://davidwalsh.name/javascript-debounce-function
 */

export const debounce = (func, wait, immediate) => {
  var timeout;
  return function() {
    var context = this,
      args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
};

/*
 * geojson display styles.
 */
const image = new CircleStyle({
  radius: 5,
  fill: null,
  stroke: new Stroke({ color: "red", width: 4 })
});

const styles = {
  Point: new Style({
    image: image
  }),
  LineString: new Style({
    stroke: new Stroke({
      color: "yellow",
      width: 4
    })
  }),
  MultiLineString: new Style({
    stroke: new Stroke({
      color: "yellow",
      width: 4
    })
  }),
  MultiPoint: new Style({
    image: image
  }),
  MultiPolygon: new Style({
    stroke: new Stroke({
      color: "yellow",
      width: 4
    }),
    fill: new Fill({
      color: "rgba(255, 0, 0, 0.3)"
    })
  }),
  Polygon: new Style({
    stroke: new Stroke({
      color: "blue",
      lineDash: [4],
      width: 4
    }),
    fill: new Fill({
      color: "rgba(0, 0, 255, 0.1)"
    })
  }),
  GeometryCollection: new Style({
    stroke: new Stroke({
      color: "magenta",
      width: 2
    }),
    fill: new Fill({
      color: "magenta"
    }),
    image: new CircleStyle({
      radius: 10,
      fill: null,
      stroke: new Stroke({
        color: "magenta"
      })
    })
  }),
  Circle: new Style({
    stroke: new Stroke({
      color: "red",
      width: 2
    }),
    fill: new Fill({
      color: "rgba(255,0,0,0.2)"
    })
  })
};

/*
 * get the right style for a geojson.
 * @param {object} feature - geojson feature.
 * @returns {object} ol/Style object.
 */
const styleFunction = function(feature) {
  return styles[feature.getGeometry().getType()];
};

/*
 * Adds a Geojson Object to the openlayers map
 * @param {object} geojson - valid geojson object
 * @returns {object} geojsonLayer - ol VectorLayer instance or null in case of failure
 */
export const displayGeojson = ({ geojson, map } = {}) => {
  if (!geojson || !map) {
    return false;
  }
  removeGeojsonOverlays(map);
  const vectorSource = createOlVectorSource(geojson);
  const geojsonLayer = new VectorLayer({
    source: vectorSource,
    style: styleFunction,
    zIndex: map.getLayers().getLength()
  });
  geojsonLayer.type = "geojson";
  map.addLayer(geojsonLayer);
  const extent = vectorSource.getExtent();
  map.getView().setCenter(getCenter(extent));
  return geojsonLayer;
};

/*
 * Removes every Geojson overlay from the openlayers map
 * @param {object} map - openlayers map object.
 * @returns {boolean} true in case of success, false otherwise.
 */
export const removeGeojsonOverlays = map => {
  if (!map) {
    return false;
  }
  map.getLayers().forEach(layer => {
    if (layer.type === "geojson") {
      map.removeLayer(layer);
    }
  });
  return true;
};
/*
 * creates an openLayers vector source object based on geojson.
 * @param {object} geojson - the geojson used by the source.
 * @returns {object} VectorSource - ol/source/Vector object
 */
const createOlVectorSource = geojson => {
  return new VectorSource({
    features: new GeoJSON().readFeatures(geojson)
  });
};

/*
 * opens the sidebar to display legends, infos etc.
 * @param {object} params
 * @param {DomElement} params.content - the content to display inside the sidebar.
 */
export const openSidebar = ({ content = null } = {}) => {
  sidebar.style.transform = "scale(1)";
  if (content) {
    sidebarContent.appendChild(content);
  }
};

export const closeSidebar = () => {
  sidebarContent.innerHTML = "";
  sidebar.style.transform = "scale(0,1)";
};
