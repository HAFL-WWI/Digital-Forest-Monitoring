import useCase1ImageWebp from "url:../img/Use-Case1_600.webp";
import useCase2ImageWebp from "url:../img/Use-Case2_600.webp";
import useCase3ImageWebp from "url:../img/Use-Case3_600.webp";
import geoservicesWebp from "url:../img/geoservices.webp";
import wikiImageWebp from "url:../img/wiki_preview_tile-01.webp";
import useCase1Image from "url:../img/Use-Case1_600.jpg";
import useCase2Image from "url:../img/Use-Case2_600.jpg";
import useCase3Image from "url:../img/Use-Case3_600.jpg";
import geoservices from "url:../img/geoservices.jpg";
import wikiImage from "url:../img/wiki_preview_tile-01.png";
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
        imageWebp: useCase1ImageWebp,
        title: "Jährliche Veränderung",
        subtitle: "Geodaten: Alexandra Erbach, HAFL",
        description:
          "Der Wald verändert sich ständig. Hier können Sie sehen, " +
          "wo Veränderungen z.B. durch Holzschläge stattgefunden haben.",
        linktext: "zum viewer",
        route: "/veraenderung"
      },
      stoerung: {
        image: useCase2Image,
        imageWebp: useCase2ImageWebp,
        title: "Test Sommersturmschäden 2017",
        subtitle: "Geodaten: Alexandra Erbach, HAFL",
        description:
          "Hier können Sie sehen, wo der Wald natürlichen Störungen wie z.B. " +
          "Borkenkäferbefall oder Sommersturmschäden ausgesetzt ist.",
        route: "/stoerungen",
        linktext: "zum viewer"
      },
      vitalitaet: {
        image: useCase3Image,
        imageWebp: useCase3ImageWebp,
        title: "Hinweiskarten zur Vitalität",
        subtitle: "Geodaten: Alexandra Erbach, HAFL",
        description:
          "Trockenheit führte in den vergangen Jahren vermehrt zu Waldschäden. " +
          "Hier finden Sie Hinweiskarten zur Vitalität der Wälder.",
        route: "/vitalitaet",
        linktext: "zum viewer"
      },
      geodienste: {
        image: geoservices,
        imageWebp: geoservicesWebp,
        title: "Geodienste",
        subtitle: "Services: karten-werk GmbH",
        description:
          "Die WMS, WMTS und WFS Geodienste, können Sie in Ihr GIS " +
          "importieren und mit Ihren eigenen Geodaten kombinieren.",
        route: "/services",
        linktext: "zu den Services"
      },
      wiki: {
        image: wikiImage,
        imageWebp: wikiImageWebp,
        title: "Waldmonitoring Wiki",
        subtitle: "bereitgestellt von HAFL und BAFU",
        description:
          "Das Wiki bietet Austauschmöglichkeiten, Hintergrundwissen und Einsatzbeispiele der Waldmonitoring-Anwendungen.",
        route: "https://wiki.waldmonitoring.ch/index.php/Hauptseite",
        linktext: "zum Wiki"
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
    },
    /*
     * opens a route.
     * @param {string} route - internal or external url.
     * @returns void
     */
    navigate: route => {
      if (!route) {
        return;
      }
      if (route.indexOf("https://") !== -1) {
        // external url
        window.open(route, "_self");
        return;
      }
      // internal routing
      router.navigate(route);
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
    createCard: ({
      image,
      imageWebp,
      title,
      subtitle,
      description,
      linktext,
      route
    }) => {
      const cell = document.createElement("div");
      const card = document.createElement("div");
      const cardPrimaryAction = document.createElement("div");
      const cardMedia = document.createElement("div");
      const picture = document.createElement("picture");
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
        homepageUtil.controller.navigate(route);
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
      cardPrimaryAction.addEventListener("click", () => {
        homepageUtil.controller.navigate(route);
      });
      picture.innerHTML = `
      <source type="image/webp" srcset="${imageWebp}" />
      <img
      src="${image}"
      alt="${title}"
      style="object-fit:cover; max-width:100%" />`;
      cardMedia.appendChild(picture);
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
