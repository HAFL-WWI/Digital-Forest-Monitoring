import { WFS, GML } from "ol/format";
import VectorSource from "ol/source/Vector";

class WfsTransationEngine {
  constructor(map) {
    this.map = map;
    this.formatWFS = new WFS();
    this.formatGML = new GML({
      featureNS: "https://geoserver.karten-werk.ch/wfs/karten-werk",
      featurePrefix: "karten-werk",
      featureType: "ndvi_decrease_crowd_2021_2020",
      srsName: "EPSG:3857"
    });
    this.xs = new XMLSerializer();
  }
  getVectorSources() {
    const layers = this.map.getLayers();
    const vectorSources = [];
    layers.forEach(layer => {
      if (layer.getSource() instanceof VectorSource) {
        vectorSources.push(layer.getSource());
      }
    });
    return vectorSources;
  }
  clearVectorSources() {
    const sources = this.getVectorSources();
    if (sources.length > 0) {
      sources.forEach(source => source.refresh());
    }
  }
  transactWFS(mode, feature) {
    let node = null;
    switch (mode) {
      case "insert":
        node = this.formatWFS.writeTransaction(
          [feature],
          null,
          null,
          this.formatGML
        );
        break;
      case "update":
        node = this.formatWFS.writeTransaction(
          null,
          [feature],
          null,
          this.formatGML
        );
        break;
      case "delete":
        node = this.formatWFS.writeTransaction(
          null,
          null,
          [feature],
          this.formatGML
        );
        break;
      default:
        break;
    }
    const payload = this.xs.serializeToString(node);
    const url = "https://geoserver.karten-werk.ch/wfs/ows";
    return fetch(url, {
      method: "POST",
      body: payload
    })
      .then(response => {
        if (response.ok === false) {
          throw new Error("Ihre Angaben konnten nicht gespeichert werden");
        }
        return response.text();
      })
      .then(text => {
        this.clearVectorSources();
        return text;
      });
  }
}

export default WfsTransationEngine;
