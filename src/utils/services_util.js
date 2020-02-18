const servicesUtil = {
  model: {
    /*
     * the element with the homepage content.
     */
    content: document.getElementsByClassName("content")[0],
    /*
     * homepage jumbotron text.
     */
    jumbotronText:
      "Unsere Geodienste können auf vielfältige Art genutzt werden. " +
      "Sie können Sie in Ihr GIS einbinden und so mit Ihren eigenen Geodaten " +
      "kombinieren oder auch in andere Applikationen wie z.B. " +
      "die Collector App von Esri einbinden.",
    /*
     * content for every card on the hompage.
     */
    cards: {
      veraenderung: {
        title: "Web Map Service (WMS)",
        subtitle: "Provided by: karten-werk GmbH",
        description: `Dieser OGC konforme WMS liefert Kartenbilder- Layer und Legendeninformationen.`,
        serviceUrl:
          "https://geoserver.karten-werk.ch/wms?request=GetCapabilities",
        videoUrl: "https://www.youtube.com/embed/g7t_tz2OJpg"
      },
      stoerung: {
        title: "Web Map Tile Service (WMTS)",
        subtitle: "Provided by: karten-werk GmbH",
        description: `Der WMTS Service liefert vorprozessierte (gecachte) Bilder und ist somit schneller als der WMS Service.
          Er eignet sich gut zum Einbinden in Web Applikationen wo man nicht immer mit einem schneller Internet rechnen kann.`,
        serviceUrl:
          "https://geoserver.karten-werk.ch/gwc/service/wmts?request=getCapabilities",
        videoUrl: "https://www.youtube.com/embed/g7t_tz2OJpg"
      },
      geodienste: {
        title: "Web Feature Service (WFS)",
        subtitle: "Provided by: karten-werk GmbH",
        description: `Der WFS Service lierfert Vektor Geometrien inklusive Attribut Informationen.
          Er lässt sich in verschiedene GIS Systemen einbinden und bei Bedarf kann man die Daten exportieren und lokal abspeichern.`,
        serviceUrl:
          "https://geoserver.karten-werk.ch/wfs?request=GetCapabilities",
        videoUrl: "https://www.youtube.com/embed/aZbNjFLe884"
      }
    }
  },
  controller: {
    /*
     * calls the necessary functions to display the hompage.
     */
    init: () => {
      servicesUtil.controller.removeContent();
      servicesUtil.controller.createJumbotron();
      servicesUtil.controller.createServiceCards();
    },
    /*
     * removes 'old' content like viewers, services etc.
     */
    removeContent: () => {
      servicesUtil.model.content.innerHTML = "";
    },
    /*
     * displays the jumbotron.
     */
    createJumbotron: () => {
      const jumbotron = servicesUtil.view.createJumbotron(
        servicesUtil.model.jumbotronText
      );
      servicesUtil.model.content.appendChild(jumbotron);
    },
    /*
     * creates all the grid with the cards on the homepage.
     * does not have any parameters, but uses the model.cards object and some view functions to get the job done.
     * @returns {DocumentFragment} - The grid with all the cards that were attached to the DOM.
     */
    createServiceCards: () => {
      const grid = servicesUtil.view.createGrid();
      const cards = document.createDocumentFragment();
      for (const card in servicesUtil.model.cards) {
        const cardElement = servicesUtil.view.createCard(
          servicesUtil.model.cards[card]
        );
        cards.appendChild(cardElement);
      }
      grid.firstChild.appendChild(cards);
      servicesUtil.model.content.appendChild(grid);
      return grid;
    }
  },
  view: {
    /*
     * creates a jumbotron element.
     * @param {string} text - the text to display inside the jumbotron.
     * @returns {HTMLElement} jumbotron - div cotaining the jumbotron.
     */
    createJumbotron: text => {
      const jumbotron = document.createElement("div");
      const jumbotronText = document.createElement("div");
      jumbotron.classList.add("jumbotron");
      jumbotronText.classList.add("jumbotron__text");
      jumbotronText.innerHTML = text;
      jumbotron.appendChild(jumbotronText);
      return jumbotron;
    },
    /*
     * creates the grid layout containing the cards.
     * @returns {HTMLElement} grid - a div with a MDCGrid inside.
     */
    createGrid: () => {
      const grid = document.createElement("div");
      const gridInner = document.createElement("div");
      grid.classList.add("mdc-layout-grid");
      gridInner.classList.add("mdc-layout-grid__inner");
      grid.appendChild(gridInner);
      return grid;
    },
    /*
     creates a html card element.
     @param {object} params - object with function parameters.
     @param {string} params.image - path to the card image.
     @param {string} params.title - card title.
     @param {string} params.subtitle - card subtitle.
     @param {string} params.description - card description.
     @param {string} params.route - the url to open when the user clicks on the card.
     @returns {HTMLElement} cell - a single grid cell containing a card Element.
    */
    createCard: ({ videoUrl, title, subtitle, description, serviceUrl }) => {
      const cell = document.createElement("div");
      const card = document.createElement("div");
      const cardPrimaryAction = document.createElement("div");
      const cardMedia = document.createElement("div");
      const cardTitleContainer = document.createElement("div");
      const cardTitle = document.createElement("h2");
      const cardSubTitle = document.createElement("h3");
      const cardDescription = document.createElement("div");
      const cardActions = document.createElement("div");
      cardActions.style.flexDirection = "column";
      cardActions.style.alignItems = "flex-start";
      const serviceTitle = document.createElement("h5");
      serviceTitle.style.margin = "0 0 8px 0";
      serviceTitle.innerHTML = "URL:";
      const serviceLink = document.createElement("textarea");
      serviceLink.value = serviceUrl;
      serviceLink.style.fontSize = "14px";
      serviceLink.style.width = "100%";
      cardActions.appendChild(serviceTitle);
      cardActions.appendChild(serviceLink);
      const cardActionButtons = document.createElement("div");
      cardTitle.innerHTML = title;
      cardDescription.innerHTML = description;
      cardSubTitle.innerHTML = subtitle;

      cell.classList.add(
        "mdc-layout-grid__cell",
        "mdc-layout-grid__cell--span-4"
      );
      card.classList.add("mdc-card", "homepage-card");
      cardPrimaryAction.classList.add(
        "mdc-card__primary-action",
        "homepage-card__primary-action"
      );
      cardPrimaryAction.addEventListener("click", () =>
        window.open(serviceUrl, "_top")
      );
      cardMedia.classList.add("homepage-card__media");
      cardMedia.innerHTML = `<iframe width="100%" height="100%" src="${videoUrl}" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;
      cardTitleContainer.classList.add("homepage-card__primary");
      cardTitle.classList.add(
        "homepage-card__title",
        "mdc-typography",
        "mdc-typography--headline6"
      );
      cardSubTitle.classList.add(
        "homepage-card__subtitle",
        "mdc-typography",
        "mdc-typography--subtitle2"
      );
      cardDescription.classList.add(
        "homepage-card__secondary",
        "mdc-typography",
        "mdc-typography--body2"
      );
      cardActions.classList.add("mdc-card__actions");
      cardActionButtons.classList.add("mdc-card__action-buttons");
      cell.appendChild(card);
      card.appendChild(cardPrimaryAction);
      cardPrimaryAction.appendChild(cardMedia);
      cardPrimaryAction.appendChild(cardTitleContainer);
      cardTitleContainer.appendChild(cardTitle);
      cardTitleContainer.appendChild(cardSubTitle);
      cardPrimaryAction.appendChild(cardDescription);
      card.appendChild(cardActions);
      cardActions.appendChild(cardActionButtons);
      return cell;
    }
  }
};

export default servicesUtil;
