import useCase1Image from "url:../img/Use-Case1_600.jpg";
import useCase2Image from "url:../img/Use-Case2_600.jpg";
import useCase3Image from "url:../img/Use-Case3_600.jpg";
import geoservices from "url:../img/geoservices.jpg";
import projektbeschriebImage from "url:../img/projektbeschrieb.jpg";
import { router } from "./router";
import { createGrid } from "./main_util";
const homepageUtil = {
  model: {
    /*
     * the element with the homepage content.
     */
    content: document.getElementsByClassName("content")[0],
    /*
     * homepage jumbotron text.
     */
    jumbotronText:
      "Auf dieser Seite finden Sie Links zu Kartenviewern und Geodiensten " +
      "welche verschiedenste Produkte wie Veränderungen oder Störungen im " +
      "Wald visualisieren. Quelle der Geodaten sind die frei verfügbaren " +
      "Sentinel Satellitenbilder. Alle angebotenen Karten/Dienste beziehen " +
      "sich ausschliesslich auf die Schweiz.",
    /*
     * content for every card on the hompage.
     */
    cards: {
      veraenderung: {
        image: useCase1Image,
        title: "Jährliche Veränderung",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Der Wald verändert sich ständig. Hier können Sie sehen, " +
          "wo Veränderungen z.B. durch Holzschläge stattgefunden haben.",
        linktext: "zum viewer",
        route: "/veraenderung"
      },
      stoerung: {
        image: useCase2Image,
        title: "Test Sommersturmschäden 2017",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Hier können Sie sehen, wo der Wald natürlichen Störungen wie z.B. " +
          "Borkenkäferbefall oder Sommersturmschäden ausgesetzt ist.",
        route: "/stoerungen",
        linktext: "zum viewer"
      },
      vitalitaet: {
        image: useCase3Image,
        title: "Hinweiskarten zur Vitalität",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Trockenheit führte in den vergangen Jahren vermehrt zu Waldschäden. " +
          "Hier finden Sie Hinweiskarten zur Vitalität der Wälder.",
        route: "/vitalitaet",
        linktext: "zum viewer"
      },
      geodienste: {
        image: geoservices,
        title: "Geodienste",
        subtitle: "Services: karten-werk GmbH",
        description:
          "Die WMS, WMTS und WFS Geodienste, können Sie in Ihr GIS " +
          "importieren und mit Ihren eigenen Geodaten kombinieren.",
        route: "/services",
        linktext: "zu den Services"
      },
      projektbeschrieb: {
        image: projektbeschriebImage,
        title: "Projektbeschrieb",
        subtitle: "Hintergrundwissen und Videoanleitungen",
        description:
          "Auf dieser Seite finden Sie Hinweise zur korrekten Verwendung der Kartenviewer und Geodienste " +
          "sowie Videoanleitungen und Hintergrundinformationen.",
        route: "/projektbeschrieb",
        linktext: "zum Projektbeschrieb"
      }
    }
  },
  controller: {
    /*
     * calls the necessary functions to display the hompage.
     */
    init: () => {
      homepageUtil.controller.removeContent();
      homepageUtil.controller.createJumbotron();
      homepageUtil.controller.createHomepageCards();
    },
    /*
     * removes 'old' content like viewers, services etc.
     */
    removeContent: () => {
      homepageUtil.model.content.innerHTML = "";
    },
    /*
     * displays the jumbotron.
     */
    createJumbotron: () => {
      const jumbotron = homepageUtil.view.createJumbotron(
        homepageUtil.model.jumbotronText
      );
      homepageUtil.model.content.appendChild(jumbotron);
    },
    /*
     * creates all the grid with the cards on the homepage.
     * does not have any parameters, but uses the model.cards object and some view functions to get the job done.
     * @returns {DocumentFragment} - The grid with all the cards that were attached to the DOM.
     */
    createHomepageCards: () => {
      const grid = createGrid();
      const cards = document.createDocumentFragment();
      for (const card in homepageUtil.model.cards) {
        const cardElement = homepageUtil.view.createCard(
          homepageUtil.model.cards[card]
        );
        cards.appendChild(cardElement);
      }
      grid.firstChild.appendChild(cards);
      homepageUtil.model.content.appendChild(grid);
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
     creates a html card element.
     @param {object} params - object with function parameters.
     @param {string} params.image - path to the card image.
     @param {string} params.title - card title.
     @param {string} params.subtitle - card subtitle.
     @param {string} params.description - card description.
     @param {string} params.route - the url to open when the user clicks on the card.
     @returns {HTMLElement} cell - a single grid cell containing a card Element.
    */
    createCard: ({ image, title, subtitle, description, linktext, route }) => {
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
      actionButton.innerHTML = linktext;

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

export default homepageUtil;
