import { change_overlay_colors } from "./main_util";
import Overlay from "ol/Overlay";
import { Stroke, Style, Fill, Icon } from "ol/style";
import WfsTransationEngine from "./WfsTransactionEngine";
const questionmark = new URL("../img/question-mark.png", import.meta.url);
const clearcut = new URL("../img/clearcut.png", import.meta.url);
const umbrella = new URL("../img/umbrella.png", import.meta.url);
const wind = new URL("../img/wind.png", import.meta.url);
const beetle = new URL("../img/beetle.png", import.meta.url);
const avalanche = new URL("../img/snow-avalanche.png", import.meta.url);
const other = new URL("../img/other.png", import.meta.url);
class Crowdsourcing {
  constructor(map) {
    this.map = map;
    this.editableProps = [
      "korrekt",
      "kategorie",
      "groessenordnung",
      "kommentar",
      "staerke",
      "datum",
      "kontakt_name"
    ];
    this.fieldMappings = {
      area: "Fläche (m2)",
      meandiff: "Vitalitätsreduktion",
      validiert: "Fläche validiert?",
      ereignisdatum: "Genaues Datum?",
      flaeche_korrekt: "Stimmt Fläche?",
      forstlicher_eingriff: "Forstlicher Eingriff",
      grund_veraenderung: "Grund der Veränderung",
      deckungsgrad_vor: "Deckungsgrad VORHER",
      deckungsgrad_nach: "Deckungsgrad NACHHER",
      kommentar: "Kommentar",
      email: "E-Mail Adresse"
    };
    this.categories = [
      { value: "unbekannt", text: "Unbekannt", color: "rgba(255,0,0,1)" },
      {
        value: "schirmhieb",
        text: "Schirmhieb",
        color: "rgba(255,0,0,1)"
      },
      { value: "räumung", text: "Räumung", color: "rgba(255,0,0,1)" },
      {
        value: "sturmschaden",
        text: "Sturmschaden",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "borkenkäfer",
        text: "Borkenkäfer",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "lawinenschaden",
        text: "Lawinenschaden",
        color: "rgba(255,0,0,1)"
      },
      { value: "sonstiges", text: "Sonstiges", color: "rgba(255,0,0,1)" }
    ];
    this.features = {};
    this.formDataList = [];
    /*
     * @TODO:
     * Every Feature gets styled, regardless of if it is the latest one or not.
     * this obscures the border color with different colors if there are different
     * categories of the feature.
     */
    this.wfsStyle = feature => {
      const fillColor = "rgba(255,0,0,0)";
      let strokeColor = fillColor;
      let interiorPoints = null;
      const kategorie = feature.get("kategorie");
      let icon = "";
      const style = [
        new Style({
          fill: new Fill({ color: fillColor }),
          stroke: new Stroke({ color: strokeColor, width: 3 }),
          zIndex: 1
        })
      ];
      if (kategorie) {
        const geometry = feature.getGeometry();
        if (geometry.getType() === "MultiPolygon") {
          interiorPoints = geometry.getInteriorPoints();
        }
        if (geometry.getType() === "Polygon") {
          interiorPoints = geometry.getInteriorPoint();
        }
        for (let entry of this.categories) {
          if (entry.value === kategorie) {
            style[0].getStroke().setColor(entry.color);
          }
        }
        icon = this.getFillIcon(kategorie);
        style.push(
          new Style({
            geometry: interiorPoints,
            image: new Icon({
              src: icon,
              rotateWithView: true
            })
          })
        );
      }
      return style;
    };
    this.highlightStyle = new Style({
      stroke: new Stroke({
        color: "#ffff00",
        width: 2
      }),
      fill: new Fill({
        color: "rgba(255,0,0,0.5)"
      }),
      zIndex: 2
    });
    this.wfsTransactionEngine = new WfsTransationEngine(this.map);
  }

  getFillIcon(kategorie) {
    switch (kategorie) {
      case "unbekannt":
        return questionmark.href;

      case "schirmhieb":
        return umbrella.href;
      case "räumung":
        return clearcut.href;
      case "sturmschaden":
        return wind.href;
      case "borkenkäfer":
        return beetle.href;
      case "lawinenschaden":
        return avalanche.href;
      case "sonstiges":
        return other.href;
      default:
        return other.href;
    }
  }

  /*
   * this function sorts features by "erfassungsdatum" and
   * creates an object with timestamp keys and a corresponding object.
   * containing the feature. the object can eventually also hold oder properties like the table, form etc.
   * @param {array} features - ol/features.
   * @returns {object} result - {timestamp: {feature, attributeTable}}
   */
  getEnhancedFeatures(features) {
    const result = {};
    if (features.length > 0) {
      // sort features by date
      const sortedFeatures = this.sortByDate(features);
      for (let feature of sortedFeatures) {
        const date = feature.get("erfassungsdatum");
        const layername = feature.id_.split(".")[0];
        const years = layername.split("_");
        const title = `Veränderung (Zeitraum ${years[years.length - 1]}-${
          years[years.length - 2]
        })`;
        const color = change_overlay_colors[layername];
        result[date] = {
          feature,
          attributeTable: this.createFeaturePropsTable({
            props: feature.getProperties(),
            layer: { color: color.hex, title }
          })
        };
      }
    }
    return result;
  }

  /*
   * get the youngest from an array of ol/feature.
   * @param {array} features - array of ol/feature.
   * @returns {object} feature - the youngest feature in the array.
   */
  sortByDate(features) {
    const sortedFeatures = features.sort((a, b) => {
      const dateA = new Date(a.get("erfassungsdatum"));
      const dateB = new Date(b.get("erfassungsdatum"));
      return dateB - dateA;
    });
    return sortedFeatures;
  }

  /*
   * clear the popup content.
   */
  clearPopoup() {
    if (this.popup) {
      this.popup.editForm.innerHTML = "";
      this.popup.featureSelect.innerHTML = "";
      this.popup.attributeTable.innerHTML = "";
      this.popup.buttonContainer.innerHTML = "";
      this.popup.responseContainer.innerHTML = "";
    }
  }

  /*
   * clear all selected features and hide the popup.
   */
  clearSelectedFeature() {
    if (this.activeFeature) {
      this.activeFeature.feature.setStyle(undefined);
      this.overlay.setPosition(undefined);
    }
  }

  /*
   * select a vector feature on the map and display a popup with attributes.
   * @param {object} params - function parameter object.
   * @param {array} params.coordinate - [x,y] coordinate of the click event.
   * @param {object} params.features - all the features under the clicked coordinate.
   * @param {array} params.feature - the ol/Feature to highlight.
   * @returns void.
   */
  selectFeature({ coordinate, features, feature = null }) {
    this.clearPopoup();
    this.clearSelectedFeature();
    if (features.length > 0) {
      /* for each selected feature, create an object with a time key.
       * every time key contains an object with:
       * - a ol/feature
       * - a attribute table
       */
      this.features = this.getEnhancedFeatures(features);

      /* the feature to highlight is either the one from the parameter,
       * or the one under the first key of this.features.
       */
      const keys = Object.keys(this.features);
      const first = keys[0];
      this.activeFeature = feature ? feature : this.features[first];

      // highlight the first feature on the map.
      this.activeFeature.feature.setStyle(this.highlightStyle);

      // get a popup if it does not allready exist.
      if (!this.popup) {
        this.getPopup();
      }

      // add a select menu to the popup if there are more than 1 feature under the clicked coordinate.
      const notNullKeys = keys.filter(key => key !== "null");
      if (notNullKeys.length > 1) {
        this.popup.featureSelect.appendChild(
          this.getFeatureSelect(notNullKeys)
        );
        // show the select in case it was hidden by the edit form.
        this.popup.featureSelect.style.display = "block";
      }

      // if it does not exist, create a map overlay to hold the popup.
      if (!this.overlay) {
        this.overlay = this.getOverlay(this.popup.container);
        this.popup.closer.addEventListener("click", () => {
          this.overlay.setPosition(undefined);
          this.activeFeature.feature.setStyle(undefined);
          return false;
        });
      }

      // add the table with attributes to the popup.
      this.popup.attributeTable.appendChild(this.activeFeature.attributeTable);

      // get a container for the edit forms.
      const formContainer = this.getFormContainer();
      this.popup.editForm.appendChild(formContainer);

      // add the save/edit buttons to the popup.
      const buttonContainer = this.getButtonContainer(
        this.activeFeature,
        formContainer
      );
      this.popup.buttonContainer.appendChild(buttonContainer);

      // display the overlay/popup on the clicked position on the map.
      this.overlay.setPosition(coordinate);
      this.map.addOverlay(this.overlay);
    }
  }

  /*
   * gets a container (div) for the edit form.
   */
  getFormContainer() {
    const formContainer = document.createElement("div");
    formContainer.style.display = "none";
    return formContainer;
  }

  /*
   * gets the container with the save/edit buttons.
   * @param {object} activeFeature - the currently selected feature.
   * @param {htmlElement} formContainer - the div containing the edit form.
   * @returns {htmlElement} buttonContainer - the div element with the buttons.
   */
  getButtonContainer(activeFeature, formContainer) {
    const buttonContainer = document.createElement("div");
    buttonContainer.classList.add("popup__buttoncontainer");
    const saveButton = this.createButton("speichern", "save");
    saveButton.style.display = "none";
    const editButton = this.createButton("edit", "edit");
    buttonContainer.appendChild(editButton);
    buttonContainer.appendChild(saveButton);
    editButton.addEventListener("click", () => {
      /*
       * this.editForm is an object containing a key with the name of each form.
       * next we add each form to the formContainer.
       */
      this.editForm = this.getEditForm();

      for (const key of Object.keys(this.editForm)) {
        if (this.editForm[key].form) {
          formContainer.appendChild(this.editForm[key].form);
        }
      }
      requestAnimationFrame(() => {
        this.setDisplay({
          elements: [
            this.activeFeature.attributeTable,
            editButton,
            this.popup.featureSelect
          ],
          display: "none"
        });
      });

      requestAnimationFrame(() => {
        this.setDisplay({
          elements: [formContainer, saveButton],
          display: "block"
        });
      });
    });
    saveButton.addEventListener("click", e => {
      e.preventDefault();
      this.formDataList = [];
      for (const key of Object.keys(this.editForm)) {
        if (this.editForm[key].form) {
          // add  a new FormData Object for every form to the formDataList.
          this.formDataList.push(new FormData(this.editForm[key].form));
        }
      }
      const updatedProps = {};
      this.formDataList.forEach(element => {
        for (var entry of element.entries()) {
          updatedProps[entry[0]] = entry[1] || null;
        }
      });
      updatedProps.erfassungsdatum = new Date().toISOString();
      const cloneFeature = activeFeature.feature.clone();
      cloneFeature.setId(activeFeature.feature.getId());
      cloneFeature.setProperties(updatedProps);
      const wfsName = cloneFeature.getId().split(".")[0];
      this.wfsTransactionEngine.setGMLFormat(wfsName);
      this.wfsTransactionEngine
        .transactWFS("insert", cloneFeature)
        .then(response => {
          console.info(response);
          const message =
            "Ihre Angaben wurden erfolgreich gespeichert. Vielen Dank!";
          this.addTransactionMessage({ message, type: "success" });
          window.setTimeout(() => {
            this.clearPopoup();
            this.clearSelectedFeature();
          }, 2000);
        })
        .catch(errorMessage => {
          this.addTransactionMessage({ message: errorMessage, type: "error" });
        });
    });
    return buttonContainer;
  }

  /*
   * add the result message of the wfs transaction to the popup.
   * @param {object} params - function parameter object.
   * @param {string} params.message - the message to display.
   * @param {string} parmas.type - "error" or "success".
   * @returns {void}.
   */
  addTransactionMessage({ message, type }) {
    this.popup.responseContainer.innerHTML = "";
    const response = document.createElement("p");
    type === "error"
      ? (response.style.color = "red")
      : (response.style.color = "green");

    response.innerText = message;
    this.popup.responseContainer.appendChild(response);
  }

  /*
   * set the style.display property for an array of elements
   * @param {object} params - function parameter object.
   * @param {array} params.elements - htmlElemnts
   * @param {string} params.display - "none", "block" etc.
   * @returns void
   */
  setDisplay({ elements, display }) {
    for (const element of elements) {
      element.style.display = display;
    }
  }

  /*
   * creates and returns a html button with an icon and text.
   * @param {string} content - the content/title of the button.
   * @param {string} iconname - the name of the icon.
   * @returns {htmlElement} - html button element.
   */
  createButton(content, iconname) {
    const button = document.createElement("button");
    button.classList.add(
      "mdc-button",
      "mdc-button--outlined",
      "mdc-button--leading",
      "button__fullwidth"
    );
    const ripple = document.createElement("span");
    ripple.classList.add("mdc-button__ripple");
    const icon = document.createElement("i");
    icon.classList.add("material-icons", "mdc-button__icon");
    icon.ariaHidden = "true";
    icon.innerText = iconname;
    const label = document.createElement("span");
    label.classList.add("mdc-button__label");
    label.innerText = content;
    button.appendChild(ripple);
    button.appendChild(icon);
    button.appendChild(label);

    return button;
  }

  /*
   * creates all the edit forms for the crowdsourcing.
   * @returns {object} - {key:{form},....}
   */
  getEditForm() {
    const result = {};
    for (let i = 0; i < this.editableProps.length; i++) {
      const prop = this.editableProps[i];
      switch (prop) {
        case "korrekt":
          result[prop] = {
            form: this.getKorrektEditForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "kategorie":
          result[prop] = {
            form: this.getKategorieForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "groessenordnung":
          result[prop] = {
            form: this.getGroessenordnungForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "kommentar":
          result[prop] = {
            form: this.getKommentarForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "staerke":
          result[prop] = {
            form: this.getStaerkeForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "datum":
          result[prop] = {
            form: this.getDatumForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        case "kontakt_name":
          result[prop] = {
            form: this.getContactForm({
              next: this.editableProps[i + 1],
              previous: this.editableProps[i - 1]
            })
          };
          break;
        default:
          break;
      }
    }
    return result;
  }

  /*
   * gets a html form element.
   * @param {string} display - the style.display property the form should have.
   * @returns {htmlElement} form - html form.
   */
  getForm(display = "none") {
    const form = document.createElement("form");
    form.style.display = display;
    form.classList.add("popup__editform");
    return form;
  }

  /*
   * gets the form elements for the contact section.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getContactForm({ next, previous }) {
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Kontakt:");
    section.appendChild(title);
    const contactInputs = this.getContactInputs();
    section.appendChild(contactInputs);

    form.appendChild(section);
    if (previous) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form element for the ereignisdatum.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getDatumForm({ next, previous }) {
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Ereignisdatum:");
    section.appendChild(title);
    const datePicker = this.getDatePicker();
    section.appendChild(datePicker);
    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form element for the stärke select.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getStaerkeForm({ next, previous }) {
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Stärke:");
    section.appendChild(title);
    const staerkeSelect = this.getStaerkeSelect();
    section.appendChild(staerkeSelect);

    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form element for the kommentar.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getKommentarForm({ next, previous }) {
    const currentValue = this.activeFeature.feature.get("kommentar");
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Kommentar:");
    section.appendChild(title);
    const kommentarInput = this.getKommentarInput(currentValue);
    section.appendChild(kommentarInput);

    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form element for the grössenordnung in m2 input.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getGroessenordnungForm({ next, previous }) {
    const currentValue = this.activeFeature.feature.get("groessenordnung_m2");
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Grössenordnung in m<sup>2</sup>:");
    section.appendChild(title);
    const input = this.getGroessenOrdnungInput(currentValue);
    section.appendChild(input);

    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form elements for the korrekt radio buttons.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getKorrektEditForm({ next, previous }) {
    const latestValue = this.activeFeature.feature.get("korrekt");
    const form = this.getForm("block");
    const section = document.createElement("div");
    const title = this.getTitle("Ist die Fläche korrekt?");
    const correctTrue = this.getRadio({
      name: "korrekt",
      id: "radiocorrect",
      value: "ja",
      labelText: "ja",
      latestValue
    });
    const correctFalse = this.getRadio({
      name: "korrekt",
      id: "radioincorrect",
      value: "nein",
      labelText: "nein",
      latestValue
    });
    section.appendChild(title);
    section.appendChild(correctTrue);
    section.appendChild(correctFalse);
    const helperTextElement = document.createElement("div");
    helperTextElement.style.fontSize = "0.8em";
    let helperText =
      "<p>Ja - die angezeigte Fläche entspricht (annähernd) einer Ihnen bekannten Waldveränderung.</p>";
    helperText +=
      "Nein - wird fälschlicherweise als Waldveränderung angezeigt.";
    helperTextElement.innerHTML = helperText;
    section.append(helperTextElement);
    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the form element for the category select.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} form - html form element.
   */
  getKategorieForm({ next, previous }) {
    const selectedValue = this.activeFeature.feature.get("kategorie");
    const form = this.getForm();
    const section = document.createElement("div");
    const title = this.getTitle("Kategorie:");
    section.appendChild(title);
    const categorieSelect = this.getCategorySelect(selectedValue);
    section.appendChild(categorieSelect);

    form.appendChild(section);
    if (next) {
      const navButtons = this.getNavButtons({ next, previous });
      form.appendChild(navButtons);
    }
    return form;
  }

  /*
   * gets the navigation buttons for the form.
   * @param {object} params - function parameter object.
   * @param {string} params.next - the key for the next form.
   * @param {string} params.previous - the key for the previous form.
   * @returns {htmlElement} buttonContainer - html div element.
   */
  getNavButtons({ previous, next }) {
    const buttonContainer = document.createElement("div");
    buttonContainer.style.display = "flex";
    buttonContainer.style.justifyContent = "space-between";
    if (previous) {
      const previousButton = document.createElement("button");
      previousButton.style.marginTop = "16px";
      previousButton.innerText = "< zurück";
      previousButton.addEventListener("click", e => {
        e.preventDefault();
        this.showForm(previous);
      });

      buttonContainer.appendChild(previousButton);
    }
    if (next) {
      const nextButton = document.createElement("button");
      nextButton.style.marginTop = "16px";
      nextButton.innerText = "weiter >";
      nextButton.addEventListener("click", e => {
        e.preventDefault();
        this.showForm(next);
      });
      buttonContainer.appendChild(nextButton);
    }
    return buttonContainer;
  }

  /*
   * show the edit form with the particular key and hide the others.
   * @param {string} key - the key of the form to display.
   */
  showForm(key) {
    const keys = Object.keys(this.editForm);
    keys.forEach(entry => {
      if (this.editForm[entry].form) {
        this.editForm[entry].form.style.display = "none";
      }
      if (key === entry) {
        this.editForm[key].form.style.display = "block";
      }
    });
  }

  getCategorySelect(value) {
    const select = document.createElement("select");
    select.style.width = "100%";
    select.style.height = "30px";
    select.name = "kategorie";
    for (let category of this.categories) {
      select.appendChild(this.createOption(category));
    }
    if (value) {
      select.value = value;
    }
    return select;
  }

  getGroessenOrdnungInput(value) {
    const container = document.createElement("div");
    const input = this.getInput({
      type: "number",
      placeholder: "bitte ca. Fläche eingeben...",
      name: "groessenordnung_m2"
    });
    if (value) {
      input.value = value;
    }
    container.appendChild(input);
    return container;
  }

  getContactInputs() {
    const contactFields = [
      { type: "text", placeholder: "Name...", name: "kontakt_name" },
      { type: "email", placeholder: "E-Mail...", name: "kontakt_email" },
      { type: "text", placeholder: "Telefon...", name: "kontakt_telefon" }
    ];

    const container = document.createElement("div");
    for (let field of contactFields) {
      container.appendChild(this.getInput(field));
    }
    return container;
  }

  getKommentarInput(value) {
    const container = document.createElement("div");
    const textarea = document.createElement("textarea");
    textarea.name = "kommentar";
    textarea.rows = 5;
    textarea.placeholder = "bitte Kommentar eingeben...";
    textarea.style.width = "100%";
    if (value) {
      textarea.value = value;
    }
    container.appendChild(textarea);
    return container;
  }

  getStaerkeSelect() {
    const options = [
      { value: "vitalitaet", text: "Nur Vitalität" },
      { value: "einzelneBaeume", text: "Einzelne Bäume entfernt" },
      { value: "geräumt", text: "Fläche geräumt" }
    ];
    const currentValue = this.activeFeature.feature.get("staerke");
    const select = document.createElement("select");
    select.style.width = "100%";
    select.style.height = "30px";
    select.name = "staerke";
    for (let option of options) {
      select.appendChild(this.createOption(option));
    }
    if (currentValue) {
      select.value = currentValue;
    }
    return select;
  }

  /*
   * gets the select menu if there are different features under the clicked coordinate.
   * @param {array} keys - the content for the select.
   * @param {htmlElement} select - the select menu.
   */
  getFeatureSelect(keys) {
    const select = document.createElement("select");
    select.style.width = "100%";
    select.style.height = "30px";
    select.style.margin = "12px 0 0 0";
    select.style.backgroundColor = "gainsboro";
    select.name = "features";
    for (let key of keys) {
      if (key !== "latest") {
        const erfassungsdatum = key;
        const text = "Feature vom: " + key;
        const option = this.createOption({
          value: erfassungsdatum,
          text
        });
        select.appendChild(option);
      }
    }
    select.addEventListener("change", e => {
      const key = e.target.value;
      const selectedFeature = this.features[key];
      this.popup.attributeTable.innerHTML = "";
      this.popup.attributeTable.appendChild(selectedFeature.attributeTable);
      // unselect the currently active feature.
      this.activeFeature.feature.setStyle(undefined);
      // highlight the selected feature.
      selectedFeature.feature.setStyle(this.highlightStyle);
      // make the selected feature the new activeFeature
      this.activeFeature = selectedFeature;
    });
    return select;
  }

  getDatePicker() {
    const featureDate = this.activeFeature.feature.get("ereignisdatum");
    const container = document.createElement("div");
    const datePicker = this.getInput({
      type: "date",
      name: "ereignisdatum"
    });
    if (featureDate) {
      datePicker.value = featureDate.slice(0, featureDate.length - 1);
    }
    container.appendChild(datePicker);
    return container;
  }

  createOption({ value, text }) {
    const option = document.createElement("option");
    option.value = value;
    option.innerText = text;
    return option;
  }

  getInput({ type = "text", placeholder, name }) {
    const input = document.createElement("input");
    input.type = type;
    input.name = name;
    input.id = name;
    if (placeholder) {
      input.placeholder = placeholder;
    }
    const value = this.activeFeature.feature.get(name);
    if (value) {
      input.value = value;
    }
    input.style.width = "100%";
    input.style.height = "30px";
    input.style.marginBottom = "8px";
    return input;
  }

  /*
   * get a html radio element with a label.
   * @param {object} params - function parameter object.
   * @param {string} params.name - the name of the radio.
   * @param {string} params.value - the value of the radio.
   * @param {string} params.id - the id of the radio element.
   * @param {string} params.labelText - the text to label the radio.
   * @param {string} params.latestsValue - check the radio if latestValue === value.
   * @returns {documentFragment} - a documentFragment containing the radio.
   */
  getRadio({ name, value, id, labelText, latestValue }) {
    const container = document.createDocumentFragment();
    const radio = document.createElement("input");
    const label = document.createElement("label");
    label.style.paddingRight = "20px";
    label.for = id;
    label.innerText = labelText;
    radio.type = "radio";
    radio.id = id;
    radio.name = name;
    radio.value = value;
    if (latestValue && latestValue === value) {
      radio.checked = true;
    }
    container.appendChild(radio);
    container.appendChild(label);
    return container;
  }

  /*
   * get the title for a form element.
   * @param {string} titleText - the text the title should diplay.
   * @returns {htmlElement} - html header element
   */
  getTitle(titletext) {
    const title = document.createElement("h4");
    title.style.margin = "0 0 8px 0";
    title.innerHTML = titletext;
    return title;
  }

  /*
   * create a html table for feature properties to
   * display inside a popup.
   * @param {object} params - function parameter object.
   * @param {object} params.props - feature properties.
   * @param {object} params.layer - {name:layername, color:color of features}.
   * @returns {htmlElement} - html table.
   */
  createFeaturePropsTable({ props, layer } = {}) {
    const hiddenAttributes = ["geometry", "id", "fid", "kommentar", "email"];
    const keys = Object.keys(props);
    const table = document.createElement("table");
    table.style.borderColor = layer.color;
    table.classList.add("popup__attributetable");
    const row = document.createElement("tr");
    row.style.backgroundColor = layer.color;
    const td = document.createElement("td");
    td.colSpan = 2;
    td.style.color = "white";
    td.style.fontWeight = "bold";
    td.classList.add("popup__attributetable--title");
    td.innerText = layer.title;
    row.appendChild(td);
    table.appendChild(row);
    for (var i = 0; i < keys.length; i++) {
      const key = keys[i];
      if (hiddenAttributes.indexOf(key) !== -1) continue;
      const row = document.createElement("tr");
      const backgrundColor = i < 6 ? "#d6d6d6" : "#f0f0f0";
      row.style.backgroundColor = backgrundColor;
      const tdKey = document.createElement("td");
      const tdVal = document.createElement("td");
      tdKey.classList.add("popup__attributetable--td");
      tdVal.classList.add("popup__attributetable--td");
      tdKey.innerText = this.fieldMappings[key] || key;
      if (
        (key === "erfassungsdatum" || key === "ereignisdatum") &&
        props[key] !== null
      ) {
        tdVal.innerText = new Date(props[key]).toLocaleDateString("de-ch");
      } else if (key === "validiert") {
        row.style.color = "grey";
        row.style.fontStyle = "italic";
        if (tdVal.innerText.length === 0) {
          tdVal.innerText = "nein";
        }
      } else {
        tdVal.innerText = props[key];
      }

      row.appendChild(tdKey);
      row.appendChild(tdVal);
      table.appendChild(row);
    }
    return table;
  }
  /*
   * creates the html elements for a popup.
   */
  getPopup() {
    this.popup = {};
    this.popup.container = document.createElement("div");
    this.popup.container.classList.add("ol-popup");
    this.popup.closer = document.createElement("span");
    this.popup.closer.style.cursor = "pointer";
    this.popup.closer.classList.add("ol-popup-closer");
    this.popup.content = document.createElement("div");
    this.popup.content.classList.add("popup-content");
    this.popup.featureSelect = document.createElement("section");
    this.popup.attributeTable = document.createElement("section");
    this.popup.editForm = document.createElement("section");
    this.popup.buttonContainer = document.createElement("section");
    this.popup.responseContainer = document.createElement("section");
    this.popup.content.appendChild(this.popup.closer);
    this.popup.content.appendChild(this.popup.featureSelect);
    this.popup.content.appendChild(this.popup.attributeTable);
    this.popup.content.appendChild(this.popup.editForm);
    this.popup.content.appendChild(this.popup.buttonContainer);
    this.popup.content.appendChild(this.popup.responseContainer);
    this.popup.container.appendChild(this.popup.content);
  }

  /*
   * creates a ol/Overlay object
   * @param {dom Element} popup - the div element with the popup content.
   * @returns {object} - ol/Overlay instance.
   */
  getOverlay(popup) {
    return new Overlay({
      element: popup,
      autoPan: {
        animation: {
          duration: 250
        }
      }
    });
  }
}

export default Crowdsourcing;
