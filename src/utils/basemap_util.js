import TileLayer from "ol/layer/Tile";
import XYZ from "ol/source/XYZ";
export const attribution =
  "© Geodaten: <a href='https://www.swisstopo.admin.ch/de/home.html'>Swisstopo</a> | App: <a href='https://karten-werk.ch'>Karten-Werk";
/*
 * Orthophoto basemap from swisstopo
 */
export const orthoBasemap = new TileLayer({
  source: new XYZ({
    url:
      "https://wmts.geo.admin.ch/1.0.0/ch.swisstopo.swissimage/default/current/3857/{z}/{x}/{y}.jpeg",
    attributions: attribution
  })
});
orthoBasemap.name = "orthofoto";

/*
 * Vegetationshoehe basemap from bafu/swisstiopo
 */
export const vegetationBasemap = new TileLayer({
  source: new XYZ({
    url:
      "https://wmts.geo.admin.ch/1.0.0/ch.bafu.landesforstinventar-vegetationshoehenmodell/default/current/3857/{z}/{x}/{y}.png",
    attributions: attribution
  })
});
vegetationBasemap.name = "vegetationshoehe";
vegetationBasemap.setOpacity(0.6);
vegetationBasemap.setVisible(false);
