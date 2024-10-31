import {
  content,
  removeContent,
  createGrid,
  setI18nAttribute,
  GEOSERVER_BASE_URL
} from "./main_util";
const servicesUtil = {
  model: {
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
      wms: {
        title: "Web Map Service (WMS)",
        serviceUrl: `${GEOSERVER_BASE_URL}/wms?request=GetCapabilities`,
        videoUrl: "https://www.youtube.com/embed/g7t_tz2OJpg"
      },
      wmts: {
        title: "Web Map Tile Service (WMTS)",
        serviceUrl:
          "https://gwc.hosting.karten-werk.ch/gwc/service/wmts?REQUEST=getCapabilities",
        videoUrl: "https://www.youtube.com/embed/g7t_tz2OJpg"
      },
      wfs: {
        title: "Web Feature Service (WFS)",
        serviceUrl: `${GEOSERVER_BASE_URL}/wfs?request=GetCapabilities`,
        videoUrl: "https://www.youtube.com/embed/aZbNjFLe884"
      },
      wcs: {
        title: "Web Coverage Service (WCS)",
        serviceUrl: `${GEOSERVER_BASE_URL}/wcs?request=GetCapabilities`,
        videoUrl: "https://www.youtube.com/embed/0nzgaLhqFGU"
      },
      cog: {
        title: "Cloud Optimized GeoTIFF (COG)",
        serviceUrl: [
          "https://waldmonitoring.ch/raster/ndvi_anomalies",
          "https://waldmonitoring.ch/raster/vegetation_under_canopy",
          "https://waldmonitoring.ch/raster/yearly_diff"
        ],
        videoUrl: "https://www.youtube.com/embed/xWGaXfUNhv4"
      }
    }
  },
  controller: {
    /*
     * calls the necessary functions to display the hompage.
     */
    init: () => {
      removeContent();
      servicesUtil.controller.createJumbotron();
      servicesUtil.controller.createTitle();
      servicesUtil.controller.createServiceCards();
      window.translator.run();
    },

    /*
     * diplays the title
     */
    createTitle: () => {
      const title = document.createElement("h1");
      title.classList.add("page__title", "mdc-layout-grid");
      title.innerText = "Geodienste";
      setI18nAttribute({
        element: title,
        attributeValue: "services.heading"
      });
      content.appendChild(title);
    },

    /*
     * displays the jumbotron.
     */
    createJumbotron: () => {
      const jumbotron = servicesUtil.view.createJumbotron(
        servicesUtil.model.jumbotronText
      );
      content.appendChild(jumbotron);
    },
    /*
     * creates all the grid with the cards on the homepage.
     * does not have any parameters, but uses the model.cards object and some view functions to get the job done.
     * @returns {DocumentFragment} - The grid with all the cards that were attached to the DOM.
     */
    createServiceCards: () => {
      const grid = createGrid();
      const cards = document.createDocumentFragment();
      for (const card in servicesUtil.model.cards) {
        const cardElement = servicesUtil.view.createCard({
          key: card,
          attributes: servicesUtil.model.cards[card]
        });

        cards.appendChild(cardElement);
      }
      grid.firstChild.appendChild(cards);
      content.appendChild(grid);
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
      setI18nAttribute({
        element: jumbotronText,
        attributeValue: "services.jumbotron"
      });
      jumbotronText.innerHTML = text;
      jumbotron.appendChild(jumbotronText);
      return jumbotron;
    },
    /*
     * creates the service link.
     * @param {object} params - object with function parameters.
     * @param {string} params.title - the title of the service.
     * @param {string} params.serviceUrl - the url of the service.
     * @returns {HTMLElement} serviceLink - a textarea containing the service url.
     */
    createServiceLink: ({ title, serviceUrl }) => {
      const serviceLink = document.createElement("textarea");
      serviceLink.id = `${title}_textarea`;
      serviceLink.value = serviceUrl;
      serviceLink.style.fontSize = "14px";
      serviceLink.style.width = "100%";
      return serviceLink;
    },
    /*
     * creates a cog link.
     * @param {string} url - the url to display.
     * @returns {HTMLElement} listItem - a list item containing the url.
     */
    createCogLink: url => {
      const listItem = document.createElement("li");
      listItem.style.padding = "4px 0";
      const link = document.createElement("a");
      link.href = url;
      link.innerHTML = url;
      listItem.appendChild(link);
      return listItem;
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
    createCard: ({ key, attributes }) => {
      const { title, serviceUrl, videoUrl } = attributes;
      const cell = document.createElement("div");
      const card = document.createElement("div");
      const cardPrimaryAction = document.createElement("div");
      const cardMedia = document.createElement("div");
      const cardTitleContainer = document.createElement("div");
      const cardTitle = document.createElement("h2");
      setI18nAttribute({
        element: cardTitle,
        attributeValue: `services.${key}.title`
      });
      const cardSubTitle = document.createElement("h3");
      setI18nAttribute({
        element: cardSubTitle,
        attributeValue: `services.${key}.subtitle`
      });
      const cardDescription = document.createElement("div");
      setI18nAttribute({
        element: cardDescription,
        attributeValue: `services.${key}.description`
      });
      const cardActions = document.createElement("div");
      cardActions.style.flexDirection = "column";
      cardActions.style.alignItems = "flex-start";
      const serviceTitle = document.createElement("label");
      serviceTitle.setAttribute("for", `${title}_textarea`);
      serviceTitle.style.margin = "0 0 8px 0";
      serviceTitle.innerHTML = "URL:";
      let serviceLink;
      switch (key) {
        case "cog":
          serviceLink = document.createElement("ul");
          serviceLink.style.fontSize = "12px";
          serviceLink.style.margin = "0";
          serviceLink.style.padding = "0 0 0 16px";
          serviceLink.style.wordBreak = "break-all";
          serviceUrl.forEach(url => {
            const link = servicesUtil.view.createCogLink(url);
            serviceLink.appendChild(link);
          });

          break;
        default:
          serviceLink = servicesUtil.view.createServiceLink({
            title,
            serviceUrl
          });
          break;
      }

      cardActions.appendChild(serviceTitle);
      cardActions.appendChild(serviceLink);
      const cardActionButtons = document.createElement("div");

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
      cardMedia.innerHTML = `<iframe width="100%" height="100%" src="${videoUrl}" title="${title}" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>`;
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
