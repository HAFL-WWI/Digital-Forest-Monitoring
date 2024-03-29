import { router } from "./router";
import { createGrid, setI18nAttribute } from "./main_util";
const useCase1ImageWebp = new URL("../img/Use-Case1_600.webp", import.meta.url);
const useCase2ImageWebp = new URL("../img/Use-Case2_600.webp", import.meta.url);
const useCase3ImageWebp = new URL("../img/Use-Case3_600.webp", import.meta.url);
const useCase4ImageWebp = new URL("../img/Use-Case4_600.webp", import.meta.url);
const geoservicesWebp = new URL("../img/geoservices.webp", import.meta.url);
const wikiImageWebp = new URL(
  "../img/wiki_preview_tile-01.webp",
  import.meta.url
);
const useCase1Image = new URL("../img/Use-Case1_600.jpg", import.meta.url);
const useCase2Image = new URL("../img/Use-Case2_600.jpg", import.meta.url);
const useCase3Image = new URL("../img/Use-Case3_600.jpg", import.meta.url);
const geoservices = new URL("../img/geoservices.jpg", import.meta.url);
const wikiImage = new URL("../img/wiki_preview_tile-01.png", import.meta.url);
const useCase4Image = new URL("../img/Use-Case4_600.jpg", import.meta.url);
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
        state: "productive",
        route: "/veraenderung"
      },
      stoerung: {
        image: useCase2Image,
        imageWebp: useCase2ImageWebp,
        title: "Test Sommersturmschäden",
        state: "test",
        route: "/stoerungen"
      },
      vitalitaet: {
        image: useCase3Image,
        imageWebp: useCase3ImageWebp,
        title: "Hinweiskarten zur Vitalität",
        state: "productive",
        route: "/vitalitaet"
      },
      verjuengung: {
        image: useCase4Image,
        imageWebp: useCase4ImageWebp,
        title: "Hinweiskarten zur Verjüngung",
        state: "test",
        route: "/verjuengung"
      },
      geodienste: {
        image: geoservices,
        imageWebp: geoservicesWebp,
        title: "Geodienste",
        state: "productive",
        route: "/services"
      },
      wiki: {
        image: wikiImage,
        imageWebp: wikiImageWebp,
        title: "Waldmonitoring Wiki",
        state: "productive",
        route: "https://wiki.waldmonitoring.ch/index.php/Hauptseite"
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
      window.translator.run();
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
        const cardElement = homepageUtil.view.createCard({
          key: card,
          attributes: homepageUtil.model.cards[card]
        });
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
    createJumbotron: () => {
      const jumbotron = document.createElement("div");
      const jumbotronText = document.createElement("div");
      jumbotron.classList.add("jumbotron");
      jumbotronText.classList.add("jumbotron__text");
      setI18nAttribute({
        element: jumbotronText,
        attributeValue: "homepage.jumbotron"
      });
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
    createCard: ({ key, attributes }) => {
      const { image, imageWebp, title, state, route } = attributes;
      const cell = document.createElement("div");
      const card = document.createElement("div");
      if (state === "test") {
        card.classList.add("test");
        const ribbon = document.createElement("div");
        ribbon.classList.add("ribbon", "ribbon-top-left");
        const ribbonText = document.createElement("span");
        ribbonText.innerText = "test";
        ribbon.appendChild(ribbonText);
        card.appendChild(ribbon);
      }
      const cardPrimaryAction = document.createElement("div");
      const cardMedia = document.createElement("div");
      const picture = document.createElement("picture");
      const cardTitleContainer = document.createElement("div");
      const cardTitle = document.createElement("h2");
      setI18nAttribute({
        element: cardTitle,
        attributeValue: `homepage.${key}.title`
      });
      const cardSubTitle = document.createElement("h3");
      setI18nAttribute({
        element: cardSubTitle,
        attributeValue: `homepage.${key}.subtitle`
      });
      const cardDescription = document.createElement("div");
      setI18nAttribute({
        element: cardDescription,
        attributeValue: `homepage.${key}.description`
      });
      const cardActions = document.createElement("div");
      const cardActionButtons = document.createElement("div");
      const actionButton = document.createElement("button");
      setI18nAttribute({
        element: actionButton,
        attributeValue: `homepage.${key}.linktext`
      });
      actionButton.addEventListener("click", () => {
        homepageUtil.controller.navigate(route);
      });

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
      style="object-fit:cover; max-width:100%; min-width:100%" />`;
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
