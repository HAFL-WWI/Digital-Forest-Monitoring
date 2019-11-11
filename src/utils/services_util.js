import veraenderungImage from "../img/jaehrl_veraenderung.jpg";
import sturmschaedenImage from "../img/sturmschaeden.jpg";
import geoservices from "../img/geoservices.jpg";
import { router } from "./router";
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
     * a single card must have the properties: image, title, subtitle, description, route and index.
     */
    cards: {
      veraenderung: {
        image: veraenderungImage,
        title: "Jährliche Veränderung",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Der Wald verändert sich ständig. Hier können Sie sehen, " +
          "wo Veränderungen z.B. durch Holzschläge stattgefunden haben.",
        route: "/viewer",
        index: 0
      },
      stoerung: {
        image: sturmschaedenImage,
        title: "Natürliche Störungen",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Hier können Sie sehen, wo der Wald natürlichen Störungen wie z.B. " +
          "Borkenkäferbefall oder Sommersturmschäden ausgesetzt ist.",
        route: "/viewer",
        index: 1
      },
      geodienste: {
        image: geoservices,
        title: "Geodienste",
        subtitle: "Services: karten-werk GmbH",
        description:
          "Die WMS, WMTS und WFS Geodienste, können Sie in Ihr GIS " +
          "importieren und mit Ihren eigenen Geodaten kombinieren.",
        route: "/services",
        index: 1
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
      servicesUtil.controller.createHomepageCards();
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
    createHomepageCards: () => {
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
     @param {number} params.index - the tabindex for the card.
     @returns {HTMLElement} cell - a single grid cell containing a card Element.
    */
    createCard: ({ image, title, subtitle, description, route, index }) => {
      const cell = document.createElement("div");
      const card = document.createElement("div");
      const cardPrimaryAction = document.createElement("div");
      const cardMedia = document.createElement("div");
      const cardTitleContainer = document.createElement("div");
      const cardTitle = document.createElement("h2");
      const cardSubTitle = document.createElement("h3");
      const cardDescription = document.createElement("div");
      const cardActions = document.createElement("div");
      const cardActionButtons = document.createElement("div");
      const actionButton = document.createElement("button");

      cardTitle.innerHTML = title;
      cardDescription.innerHTML = description;
      cardSubTitle.innerHTML = subtitle;
      actionButton.addEventListener("click", () => {
        router.navigate(route);
      });
      actionButton.innerHTML = "zum Viewer";

      cell.classList.add(
        "mdc-layout-grid__cell",
        "mdc-layout-grid__cell--span-4"
      );
      card.classList.add("mdc-card", "homepage-card");
      cardPrimaryAction.classList.add(
        "mdc-card__primary-action",
        "homepage-card__primary-action"
      );
      cardPrimaryAction.addEventListener("click", () => router.navigate(route));
      cardPrimaryAction.tabIndex = index;
      cardMedia.classList.add(
        "mdc-card__media",
        "mdc-card__media--16-9",
        "homepage-card__media"
      );
      cardMedia.style.backgroundImage = 'url("' + image + '")';
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
      actionButton.classList.add(
        "mdc-card__action--button-secondary",
        "mdc-button",
        "mdc-button--raised",
        "mdc-card__action",
        "mdc-card__action--button"
      );
      cell.appendChild(card);
      card.appendChild(cardPrimaryAction);
      cardPrimaryAction.appendChild(cardMedia);
      cardPrimaryAction.appendChild(cardTitleContainer);
      cardTitleContainer.appendChild(cardTitle);
      cardTitleContainer.appendChild(cardSubTitle);
      cardPrimaryAction.appendChild(cardDescription);
      card.appendChild(cardActions);
      cardActions.appendChild(cardActionButtons);
      cardActionButtons.appendChild(actionButton);
      return cell;
    }
  }
};

export default servicesUtil;
