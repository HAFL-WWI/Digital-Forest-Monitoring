import { content, removeContent, createGrid } from "./main_util";
const description_util = {
  model: {
    main_title: "Waldmonitoring Use-Cases mit Sentinel Satellitenbildern",
    authors:
      "Dominique Weber (HAFL), Alexandra Erbach (HAFL), Christian Rosset (HAFL), Hanskaspar Frei (KARTEN-WERK GmbH), Thomas Bettler (BAFU)",
    hint:
      "<div style='padding:20px 0'>August 2020</div>" +
      "<div>Auf dieser Seite finden Sie Hinweise zur korrekten Verwendung der Kartenviewer und Geodienste sowie Videoanleitungen und Hintergrundinformationen.</div>" +
      "<div style='padding:12px 0'><strong>Wichtig:</strong> Die bereitgestellten Daten und Services sind bis dato ausschliesslich für Testzwecke gedacht.</div>"
  },
  controller: {
    /*
     * calls the necessary functions to display the projektbescchrieb.
     */
    init: () => {
      removeContent();
      description_util.controller.composeDescription();
    },
    composeDescription: () => {
      const grid = createGrid();
      grid.appendChild(description_util.view.getTitle());
      grid.appendChild(description_util.view.getAuthors());
      grid.appendChild(description_util.view.getHint());
      content.appendChild(grid);
    }
  },
  view: {
    getWraper: () => {
      const wrapper = document.createElement("div");
      wrapper.classList.add("mdc-layout-grid__cell");
      return wrapper;
    },
    getTitle: () => {
      const wrapper = description_util.view.getWraper();
      const title = document.createElement("h2");
      title.innerText = description_util.model.main_title;
      wrapper.appendChild(title);
      return wrapper;
    },
    getAuthors: () => {
      const wrapper = description_util.view.getWraper();
      const authors = document.createElement("span");
      authors.style.fontSize = "12px";
      authors.innerText = description_util.model.authors;
      wrapper.appendChild(authors);
      return wrapper;
    },
    getHint: () => {
      const wrapper = description_util.view.getWraper();
      wrapper.innerHTML = description_util.model.hint;
      return wrapper;
    }
  }
};

export default description_util;
