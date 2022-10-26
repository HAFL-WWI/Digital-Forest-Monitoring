import TileLayer from "ol/layer/Tile";
import XYZ from "ol/source/XYZ";
export const attribution =
  "© <span vanilla-i18n='viewer.attribution.geodaten'>Geodaten</span>: <a href='https://www.swisstopo.admin.ch/de/home.html'>Swisstopo</a> & <a href='https://www.bfh.ch/hafl/de/'>HAFL</a> | App & Services: <a href='https://karten-werk.ch'>Karten-Werk";
/*
 * Orthophoto basemap from swisstopo
 */
export const orthoBasemap = new TileLayer({
  visible: false,
  source: new XYZ({
    url:
      "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/3857/{z}/{x}/{y}.jpeg",
    attributions: attribution
  })
});
orthoBasemap.name = "orthofoto";

/*
 * SW basemap from swisstopo
 */
export const swBasemap = new TileLayer({
  visible: false,
  source: new XYZ({
    url:
      "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.pixelkarte-grau/default/current/3857/{z}/{x}/{y}.jpeg",
    attributions: attribution
  })
});
swBasemap.name = "Karte SW";

/*
 * Vegetationshoehe basemap from bafu/swisstiopo
 */
export const vegetationBasemap = new TileLayer({
  visible: false,
  source: new XYZ({
    url:
      "https://wmts.geo.admin.ch/1.0.0/ch.bafu.landesforstinventar-vegetationshoehenmodell/default/current/3857/{z}/{x}/{y}.png",
    attributions: attribution
  })
});
vegetationBasemap.name = "vegetationshoehe";
vegetationBasemap.setOpacity(0.6);
vegetationBasemap.setVisible(false);
