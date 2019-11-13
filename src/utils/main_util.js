/*
 * changes the top appbar title.
 * @param {string} title - the new title to display.
 * @returns {boolean} - true if title changed successfully, false otherwise.
 */
export const changeTitle = title => {
  if (!title) {
    return false;
  }
  document.getElementsByClassName(
    "mdc-top-app-bar__title"
  )[0].innerHTML = title;
  return true;
};

/*
 * updates the title in the appBar.
 * @param {string} title - the text that should be used as the title.
 * @returns void.
 */
export const setTitle = title => {
  document.getElementsByClassName(
    "mdc-top-app-bar__title"
  )[0].innerHTML = title;
};

/*
 * calculates the title based on the window.width.
 * @returns {string} title - title to use based on the current window.width.
 */
export const getTitle = () => {
  const width = window.innerWidth;
  const title =
    width <= 500
      ? "Waldmonitoring"
      : "Waldmonitoring mit Sentinel Satellitenbildern";
  return title;
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
