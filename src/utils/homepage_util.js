import veraenderungImage from "../img/jaehrl_veraenderung.jpg";
import sturmschaedenImage from "../img/sturmschaeden.jpg";
import geoservices from "../img/geoservices.jpg";
const homepageUtil = {
  model: {
    /*
     * content for every card on the hompage.
     * a single card must have the properties: image, title, subtitle, description, link and index.
     */
    cards: {
      veraenderung: {
        image: veraenderungImage,
        title: "Jährliche Veränderung",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Dieser Viewer visualisiert jährliche Veränderungen welche im Wald stattfinden. " +
          "Man sieht z.B. wo Holzschläge oder Zwangsnutzungen ausgeführt wurden.",
        link: "https://test.ch",
        index: 0
      },
      stoerung: {
        image: sturmschaedenImage,
        title: "Natürliche Störungen",
        subtitle: "Geodaten: Dominique Weber, HAFL",
        description:
          "Hier können Sie sehen, wo der Wald natürlichen Störungen wie z.B. " +
          "Borkenkäferbefall oder Sommersturmschäden ausgesetzt ist.",
        link: "https://test.ch",
        index: 1
      },
      geodienste: {
        image: geoservices,
        title: "Geodienste",
        subtitle: "Services: karten-werk GmbH",
        description:
          "Die WMS, WMTS und WFS Geodienste, können Sie in Ihr GIS " +
          "importieren und mit Ihren eigenen Geodaten kombinieren.",
        link: "https://test.ch",
        index: 1
      }
    }
  },
  controller: {
    /*
     * creates all the cards on the homepage.
     * does not have any parameters, but uses the model.cards object and the view function to get the job done.
     * @returns {DocumentFragment} - All the cards that were attached to the DOM.
     */
    createHomepageCards: () => {
      const cards = document.createDocumentFragment();
      for (const card in homepageUtil.model.cards) {
        const cardElement = homepageUtil.view.createCard(
          homepageUtil.model.cards[card]
        );
        cards.appendChild(cardElement);
      }
      // attach the cards to the dom
      const cardContainer = document.getElementsByClassName(
        "mdc-layout-grid__inner"
      )[0];
      cardContainer.appendChild(cards);
      return cards;
    }
  },
  view: {
    /*
     creates a html card element.
     @param {object} params - object with function parameters.
     @param {string} params.image - path to the card image.
     @param {string} params.title - card title.
     @param {string} params.subtitle - card subtitle.
     @param {string} params.description - card description.
     @param {string} params.link - the url to open when the user clicks on the card.
     @param {number} params.index - the tabindex for the card.
     @returns {HTMLElement} cell - a single grid cell containing a card Element.
    */
    createCard: ({ image, title, subtitle, description, link, index }) => {
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
        console.log("button clicked...");
        window.open(link);
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

export default homepageUtil;
