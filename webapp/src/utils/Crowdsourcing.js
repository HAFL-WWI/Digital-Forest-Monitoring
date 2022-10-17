import { change_overlay_colors, setI18nAttribute } from "./main_util";
import Overlay from "ol/Overlay";
import { Stroke, Style, Fill } from "ol/style";
import WfsTransationEngine from "./WfsTransactionEngine";

class Crowdsourcing {
  constructor(map) {
    this.map = map;
    this.fieldMappings = {
      area: { name: "Fläche (m<sup><small>2</small></sup>)", editable: false },
      meandiff: { name: "Vitalitätsreduktion", editable: false },
      validiert: { name: "Fläche validiert?", editable: true },
      ereignisdatum: { name: "Genaues Datum?", editable: true },
      flaeche_korrekt: { name: "Stimmt Fläche?", editable: true },
      flaeche_korrekt_bemerkung: { name: "Fläche Bemerkung", editable: true },
      forstlicher_eingriff: { name: "Forstlicher Eingriff?", editable: true },
      grund_veraenderung: { name: "Grund der Veränderung?", editable: true },
      deckungsgrad_vor: { name: "Deckungsgrad VORHER?", editable: true },
      deckungsgrad_nach: { name: "Deckungsgrad NACHHER?", editable: true },
      kommentar: { name: "Kommentar", editable: true },
      email: { name: "E-Mail Adresse", editable: true }
    };
    this.categories = [
      {
        value: "verjuengungsschlag",
        text: "Verjüngungsschlag",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "sturmereignis",
        text: "Sturmereignis",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "durchforstung",
        text: "Durchforstung",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "borkenkäfer",
        text: "Borkenkäfer",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "dauerwaldpflege",
        text: "Dauerwaldpflege",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "lawinenschaden",
        text: "Lawinenschaden",
        color: "rgba(255,0,0,1)"
      },
      {
        value: "vitalitätsverlust",
        text: "Vitalitätsverlust",
        color: "rgba(255,0,0,1)"
      },
      { value: "sonstiges", text: "Sonstiges", color: "rgba(255,0,0,1)" }
    ];
    this.formTabs = ["BASISDATEN", "GRUND", "KOMMENTAR"];
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
      const flaecheKorrekt = feature.get("flaeche_korrekt");
      let strokeColor = "rgba(255,0,0,0)";
      switch (flaecheKorrekt) {
        case "ja":
          strokeColor = "rgba(124,252,0,1)"; // green border
          break;
        case "nein":
          strokeColor = "rgba(255,0,0,1)"; // red border
          break;
        default:
          break;
      }
      const style = [
        new Style({
          fill: new Fill({ color: fillColor }),
          stroke: new Stroke({ color: strokeColor, width: 1 }),
          zIndex: 1
        })
      ];
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

  /*
   * this function sorts features by "validiert (erfassungsdatum)" and
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
        const { date, color, title } = this.getFeatureMetadata(feature);
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
      const dateA = new Date(a.get("validiert"));
      const dateB = new Date(b.get("validiert"));
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

      // add the save/edit buttons to the popup.
      const buttonContainer = this.getButtonContainer();
      this.popup.buttonContainer.appendChild(buttonContainer);

      // display the overlay/popup on the clicked position on the map.
      this.overlay.setPosition(coordinate);
      this.map.addOverlay(this.overlay);
      window.translator.run();
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

  getFormTabs() {
    /*
     * this.editForm is an object containing a key with the name of each form.
     */
    this.editForm = this.getEditForm();
    const formSection = document.createElement("section");
    formSection.style.display = "none";
    formSection.classList.add("popup__formcontainer");
    const tabContainer = document.createElement("div");
    tabContainer.classList.add("tab");

    // next we add each form to the formSection.
    this.formTabs.forEach((tab, i) => {
      // add the tabs
      const button = document.createElement("button");
      button.classList.add("tablinks");
      button.addEventListener("click", e => this.switchTab(e, tab));
      button.innerText = tab;
      tabContainer.appendChild(button);
      // the content...
      const content = document.createElement("div");
      content.id = tab;
      content.classList.add("tabcontent");
      if (this.editForm[tab]?.form) {
        content.appendChild(this.editForm[tab].form);
      }
      // Show the first tab as a default
      if (i === 0) {
        content.style.display = "block";
        button.className += " active";
      }
      formSection.appendChild(content);
    });
    formSection.appendChild(tabContainer);
    return formSection;
  }

  /*
   * gets the container with the save/edit buttons.
   * @returns {htmlElement} buttonContainer - the div element with the buttons.
   */
  getButtonContainer() {
    const buttonContainer = document.createElement("div");
    const completionMessage = document.createElement("section");
    completionMessage.style.display = "none";
    completionMessage.id = "popup__completionmessage";
    buttonContainer.appendChild(completionMessage);
    const mandatoryMessage = document.createElement("section");
    mandatoryMessage.id = "popup__mandatorymessage";
    mandatoryMessage.classList.add("red");
    buttonContainer.appendChild(mandatoryMessage);
    buttonContainer.classList.add("popup__buttoncontainer");
    this.saveButton = this.createButton("speichern", "save");
    this.saveButton.setAttribute("disabled", "");
    this.saveButton.style.display = "none";
    const editButton = this.createButton("edit", "edit");
    buttonContainer.appendChild(editButton);
    buttonContainer.appendChild(this.saveButton);
    editButton.addEventListener("click", () => {
      // get the tabs for the edit form.
      const formContainer = this.getFormTabs();
      this.popup.editForm.innerHTML = "";
      this.popup.editForm.appendChild(formContainer);

      // add event listeners in order to show the completion status to the user
      for (const key in this.editForm) {
        const form = this.editForm[key].form;
        if (form) {
          form.addEventListener("change", () => {
            this.updateFormDataList();
            const formValues = this.getFormDataAsObject();
            this.updateCompletionStatus(formValues);
            this.updateMandatoryMessage(formValues);
          });
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
          elements: [formContainer, this.saveButton],
          display: "block"
        });
      });
      // show the completion and mandatory messages when the edit form is loaded.
      this.updateFormDataList();
      const formValues = this.getFormDataAsObject();
      this.updateCompletionStatus(formValues);
      this.updateMandatoryMessage(formValues);
      window.translator.run();
    });
    this.saveButton.addEventListener("click", e => {
      e.preventDefault();
      this.updateFormDataList();
      const updatedProps = this.getFormDataAsObject();
      // save the e-mail adress to the localStorage.
      if (updatedProps.email && updatedProps.email.length > 4) {
        localStorage.setItem("waldmonitoring_email", updatedProps.email);
      }
      updatedProps.validiert = new Date().toISOString();
      if (updatedProps.ereignisdatum) {
        updatedProps.ereignisdatum = new Date(
          updatedProps.ereignisdatum
        ).toISOString();
      } else {
        // we can not save an empty string as a date.
        delete updatedProps.ereignisdatum;
      }
      // create a new feature and give them the attributes from the form.
      const cloneFeature = this.activeFeature.feature.clone();
      // unset all editable properties in order to have no "old" values from the original feature.
      Object.keys(this.fieldMappings).forEach(key => {
        if (this.fieldMappings[key].editable) {
          cloneFeature.unset(key);
        }
      });
      cloneFeature.setId(this.activeFeature.feature.getId());
      cloneFeature.setProperties(updatedProps);
      const wfsName = cloneFeature.getId().split(".")[0];
      this.wfsTransactionEngine.setGMLFormat(wfsName);
      // save the new feature to the wfs.
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
   * checks if the mandatory fields 'ausdehnung der Fläche' and 'email' are filled out.
   * @param {object} formValues - all the properties of the form.
   * @returns {string} - "ok" when mandatory fields are filled out, otherwise a helper text for the user.
   */
  checkMandatoryFields(formValues) {
    if (!formValues.flaeche_korrekt && !formValues.email) {
      const text =
        "• Bitte beantworten sie die erste Frage. \n • Bitte EMail Kontaktadresse angeben.";
      return text;
    }
    if (!formValues.flaeche_korrekt && formValues.email) {
      const text = "• Bitte beantworten Sie die erste Frage.";
      return text;
    }
    if (formValues.flaeche_korrekt && !formValues.email) {
      const text = "• Bitte EMail-Kontaktadresse angeben.";
      return text;
    }
    return "ok";
  }

  /*
   * updates the mandatory message above the send button.
   * @param {object} formValues - all the properties of the form.
   * @returns void.
   */
  updateMandatoryMessage(formValues) {
    const mandatoryMessage = document.getElementById("popup__mandatorymessage");
    const mandatoryText = this.checkMandatoryFields(formValues);
    if (mandatoryText === "ok") {
      this.saveButton.removeAttribute("disabled");
      mandatoryMessage.innerText = "";
      mandatoryMessage.style.display = "none";
    } else {
      this.saveButton.setAttribute("disabled", "");
      mandatoryMessage.innerText = mandatoryText;
      mandatoryMessage.style.display = "block";
    }
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
    button.id = `button__${iconname}`;
    button.classList.add(
      "mdc-button",
      "mdc-button--raised",
      "mdc-card__action",
      "mdc-card__action--button"
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
    const { years, color } = this.getFeatureMetadata(
      this.activeFeature.feature
    );
    const splittedYears = years.split("-");
    for (let i = 0; i < this.formTabs.length; i++) {
      const prop = this.formTabs[i];
      switch (prop) {
        case "BASISDATEN":
          result[prop] = {
            form: this.getFlaecheForm({
              color,
              yearvon: splittedYears[0],
              yearbis: splittedYears[1]
            })
          };
          break;
        case "GRUND":
          result[prop] = {
            form: this.getUrsacheForm()
          };
          break;
        case "KOMMENTAR":
          result[prop] = {
            form: this.getErfasserForm()
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
  getEmailForm() {
    const section = document.createElement("div");
    const emailInput = this.getEmailInput();
    section.appendChild(emailInput);
    return section;
  }

  /*
   * gets the form elements for the ereignisdatum.
   * @returns {htmlElement} section - html section element.
   */
  getDatumSection({ yearvon, yearbis }) {
    const section = document.createElement("div");
    const title = this.getTitle({
      text: "Datum bekannt?",
      subtext: "Monat/Jahr der Veränderung reicht aus"
    });
    section.appendChild(title);
    const datePicker = this.getDatePicker({
      min: `${yearvon}-06-01`,
      max: `${yearbis}-06-01`,
      type: "date"
    });
    section.appendChild(datePicker);

    return section;
  }

  /*
   * gets the form element for the kommentar.
   * @returns {htmlElement} form - html form element.
   */
  getKommentarForm() {
    const currentValue = this.activeFeature.feature.get("kommentar");
    const section = document.createElement("div");
    const kommentarInput = this.getKommentarInput(currentValue);
    section.appendChild(kommentarInput);
    return section;
  }

  getFlaecheForm({ color, yearvon, yearbis }) {
    const form = this.getForm("block");
    form.appendChild(
      this.getColoredTitle({
        color,
        yearvon,
        yearbis
      })
    );
    form.appendChild(this.getKorrektEditSection());
    form.appendChild(this.getDatumSection({ yearvon, yearbis }));
    form.appendChild(
      this.getDeckungsgradRadios({
        radiotitle: "Deckungsgrad VOR",
        radioname: "deckungsgrad_vor"
      })
    );
    form.appendChild(
      this.getDeckungsgradRadios({
        radiotitle: "Deckungsgrad NACH",
        radioname: "deckungsgrad_nach"
      })
    );
    return form;
  }

  getUrsacheForm() {
    const form = this.getForm("block");
    form.appendChild(this.getForstlichereingriffSection());
    form.appendChild(this.getKategorieSection());
    return form;
  }

  getErfasserForm() {
    const form = this.getForm("block");
    form.appendChild(this.getEmailForm());
    form.appendChild(this.getKommentarForm());
    return form;
  }

  /*
   * refill the FormData with current values.
   */
  updateFormDataList() {
    // empty the list first in order to have no old values in it.
    this.formDataList = [];
    for (const key in this.editForm) {
      if (this.editForm[key].form) {
        // add  a new FormData Object for every form to the formDataList.
        this.formDataList.push(new FormData(this.editForm[key].form));
      }
    }
  }

  /*
   * create an Object with key/value pairs of each form element
   * @returns {object} data - object with keys of the form element names and values of the form element values
   */
  getFormDataAsObject() {
    const data = {};
    this.formDataList.forEach(formData => {
      const entries = Array.from(formData.entries());
      entries.forEach(entry => {
        // case when multiple values for a property, concat them.
        // for instance "Grund der Veränderung?"
        if (data[entry[0]]) {
          data[entry[0]] = data[entry[0]] + "," + entry[1];
        } else {
          data[entry[0]] = entry[1];
        }
      });
    });
    return data;
  }

  /*
   * updates the completion message above the "speichern" button.
   * @param {object} formValues - key/value pairs of the form data.
   */
  updateCompletionStatus(formValues) {
    const consideredEmpty = ["kA", "", "--"];
    const excludedFields = [
      "flaeche_korrekt_bemerkung",
      "kommentar",
      "validiert",
      "grund_veraenderung_sonstiges"
    ];
    const keys = Object.keys(formValues);
    const filled = [];
    for (const key of keys) {
      if (consideredEmpty.indexOf(formValues[key]) === -1) {
        if (excludedFields.indexOf(key) !== -1) continue;
        filled.push([key, formValues[key]]);
      }
    }
    const completionMessage = document.getElementById(
      "popup__completionmessage"
    );
    completionMessage.style.display = "block";
    const editableFields = [];
    for (const key in this.fieldMappings) {
      if (this.fieldMappings[key].editable) {
        if (excludedFields.indexOf(key) !== -1) continue;
        editableFields.push(this.fieldMappings[key]);
      }
    }
    const formCompleted = filled.length === editableFields.length;
    completionMessage.style.color = formCompleted ? "green" : "#f9aa33";
    completionMessage.innerText = `${filled.length}/${editableFields.length} Felder sind ausgefüllt.`;
    const button = document.getElementById("button__save");
    button.lastChild.innerText = formCompleted ? "senden" : "trotzdem senden";
  }

  getColoredTitle({ color, yearvon, yearbis }) {
    const coloredTitle = document.createElement("div");
    coloredTitle.style.backgroundColor = color.hex;
    coloredTitle.style.borderRadius = "4px";
    coloredTitle.style.color = "white";
    coloredTitle.style.fontWeight = "bold";
    coloredTitle.style.fontSize = "0.8em";
    coloredTitle.style.padding = "8px";
    coloredTitle.innerHTML = `Zeitraum Juni ${yearvon} - Juni ${yearbis}`;
    setI18nAttribute({
      element: coloredTitle,
      attributeValue: `popup.edit.title.${coloredTitle.innerHTML
        .split(" ")
        .join("")}`
    });

    return coloredTitle;
  }

  /*
   * gets the form elements for the korrekt radio buttons.
   * @returns {htmlElement} section - html section element.
   */
  getKorrektEditSection() {
    const latestValue = this.activeFeature.feature.get("flaeche_korrekt");
    const section = document.createElement("div");
    const title = this.getTitle({
      text: "Stimmt die Ausdehnung der Fläche? <span class='red'>*</span>",
      i18n: "popup.edit.ausdehnung.title"
    });
    const correctSelectContainer = document.createElement("section");
    correctSelectContainer.classList.add("correctselect");
    const correctSelectLabel = document.createElement("label");
    correctSelectLabel.style.fontSize = "0.8em";
    correctSelectLabel.setAttribute("for", "flaeche_korrekt_bemerkung");
    correctSelectLabel.innerText = "Bitte wählen sie eine Option...";
    setI18nAttribute({
      element: correctSelectLabel,
      attributeValue: "popup.edit.ausdehnung.options.label"
    });
    const correctSelect = this.getCorrectSelect();

    correctSelectContainer.appendChild(correctSelectLabel);
    correctSelectContainer.appendChild(correctSelect);
    const radioContainer = document.createElement("div");
    radioContainer.classList.add("popup__radiocontainer");
    const correctTrue = this.getRadio({
      name: "flaeche_korrekt",
      id: "radiocorrect",
      value: "ja",
      labelText: "ja (+-)",
      latestValue,
      i18n: "popup.edit.ausdehnung.yes"
    });
    const correctFalse = this.getRadio({
      name: "flaeche_korrekt",
      id: "radioincorrect",
      value: "nein",
      labelText: "nein",
      latestValue,
      i18n: "popup.edit.ausdehnung.no"
    });
    radioContainer.appendChild(correctTrue);
    radioContainer.appendChild(correctFalse);
    section.appendChild(title);
    section.appendChild(radioContainer);
    section.appendChild(correctSelectContainer);
    return section;
  }

  /*
   * gets the form element for the category select.
   * @returns {htmlElement} form - html form element.
   */
  getKategorieSection() {
    const selectedValue = this.activeFeature.feature.get("grund_veraenderung");

    const section = document.createElement("section");
    const title = this.getTitle({
      text: "Grund der Veränderung",
      subtext: "Mehrfachnennungen möglich"
    });
    section.appendChild(title);
    const categorieSelect = this.getCategoryCheckboxes(selectedValue);
    section.appendChild(categorieSelect);
    return section;
  }

  getCategoryCheckboxes() {
    const latestValue = this.activeFeature.feature.get("grund_veraenderung");
    let splitted = [];
    if (latestValue) splitted = latestValue.split(",");
    const checkboxSection = document.createElement("section");
    checkboxSection.classList.add("popup__checkboxcontainer");
    for (let category of this.categories) {
      const checkboxContainer = document.createElement("div");
      const checkbox = document.createElement("input");
      checkbox.type = "checkbox";
      checkbox.id = category.value;
      checkbox.name = "grund_veraenderung";
      checkbox.value = category.value;
      const label = document.createElement("label");
      label.style.fontSize = "0.66em";
      label.innerText = category.text;

      label.setAttribute("for", category.value);
      if (splitted.length > 0 && splitted.indexOf(category.value) !== -1) {
        checkbox.checked = true;
      }
      let userInput = null;
      if (category.value === "sonstiges") {
        userInput = this.getInput({
          type: "text",
          placeholder: "Grund eingeben",
          name: "grund_veraenderung_sonstiges"
        });
        userInput.classList.add("popup__checkboxcontainer_customreason");
        userInput.addEventListener("input", e => {
          if (e.target.value.length > 0) {
            checkbox.value = `sonstiges,${e.target.value}`;
            checkbox.checked = true;
          } else {
            checkbox.checked = false;
          }
          this.updateFormDataList();
          const formData = this.getFormDataAsObject();
          this.updateCompletionStatus(formData);
        });
        // if the checkbox get's unchecked, empty the user input.
        checkbox.addEventListener("change", e => {
          if (e.target.checked === false) {
            userInput.value = "";
          }
        });
        // if there is a custom user value, set it as the value for the input.
        const categoryValues = this.categories.map(category => category.value);
        splitted.forEach(value => {
          if (categoryValues.indexOf(value) === -1) {
            userInput.value = value;
          }
        });
      }
      checkboxContainer.appendChild(checkbox);
      checkboxContainer.appendChild(label);
      if (userInput) checkboxContainer.appendChild(userInput);
      checkboxSection.appendChild(checkboxContainer);
    }

    return checkboxSection;
  }

  getCorrectSelect() {
    const latestValue = this.activeFeature.feature.get(
      "flaeche_korrekt_bemerkung"
    );
    const select = document.createElement("select");
    select.style.width = "100%";
    select.style.height = "30px";
    select.name = "flaeche_korrekt_bemerkung";
    select.id = "flaeche_korrekt_bemerkung";
    const options = [
      { text: "--", i18n: "--" },
      {
        text: "Nein, es gibt hier keine Veränderung in diesem Jahr",
        i18n: "keine_veraenderung_in_diesem_jahr"
      },
      { text: "Nein, sie ist zu klein", i18n: "nein_zu_klein" },
      { text: "Nein, sie ist zu gross", i18n: "nein_zu_gross" },
      {
        text: "Nein, die Form passt überhaupt nicht",
        i18n: "nein_form_passt_nicht"
      }
    ];
    for (let option of options) {
      const selectOption = {
        value: option.text,
        text: option.text,
        i18n: `popup.edit.ausdehnung.option.${option.i18n}`
      };
      select.appendChild(this.createOption(selectOption));
    }
    select.value = latestValue || options[0].text;
    return select;
  }

  getEmailInput() {
    const localStorageEmail = localStorage.getItem("waldmonitoring_email");
    const contactFields = [
      {
        type: "email",
        placeholder: "E-Mail...",
        name: "email",
        value: localStorageEmail || "",
        updateCompletionStatus: true
      }
    ];
    const container = document.createElement("div");
    const title = this.getTitle({
      text: "E-Mail <span class='red'>*</span>",
      margin: "0"
    });
    container.appendChild(title);
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
    textarea.placeholder = "Kommentar...";
    textarea.style.width = "100%";
    textarea.addEventListener("input", () => {
      this.updateFormDataList();
      const formData = this.getFormDataAsObject();
      this.updateCompletionStatus(formData);
    });
    if (value) {
      textarea.value = value;
    }
    const title = this.getTitle({ text: "Kommentar" });
    container.appendChild(title);
    container.appendChild(textarea);
    return container;
  }

  getForstlichereingriffSection() {
    const options = [{ value: "ja" }, { value: "nein" }, { value: "kA" }];
    const latestValue =
      this.activeFeature.feature.get("forstlicher_eingriff") || "kA";
    const section = document.createElement("section");

    const title = this.getTitle({
      text: "Forstlicher Eingriff?",
      subtext: "Auf Grossteil dieser Fläche",
      margin: 0
    });
    section.appendChild(title);
    const radioContainer = document.createElement("div");
    radioContainer.classList.add("popup__radiocontainer");
    section.appendChild(radioContainer);
    options.forEach(option => {
      radioContainer.appendChild(
        this.getRadio({
          name: "forstlicher_eingriff",
          id: `forstlicher_eingriff_${option.value}`,
          value: option.value,
          labelText: option.value,
          latestValue
        })
      );
    });
    return section;
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
    select.name = "features";
    for (let key of keys) {
      if (key !== "latest") {
        const validiert = key;
        const text = "Eintrag vom: " + new Date(key).toLocaleString("de-ch");
        const option = this.createOption({
          value: validiert,
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

  getDatePicker({ min = null, max = null, type = "date" }) {
    const featureDate = this.activeFeature.feature.get("ereignisdatum");
    const container = document.createElement("div");
    const datePicker = this.getInput({
      type,
      name: "ereignisdatum",
      min,
      max
    });
    if (featureDate) {
      datePicker.value = featureDate.slice(0, featureDate.length - 1);
    }
    container.appendChild(datePicker);
    return container;
  }

  createOption({ value, text, i18n }) {
    const option = document.createElement("option");
    option.value = value;
    option.innerText = text;
    if (i18n) {
      setI18nAttribute({ element: option, attributeValue: i18n });
    }
    return option;
  }

  getInput({
    type = "text",
    placeholder,
    name,
    min,
    max,
    value,
    updateCompletionStatus = false
  }) {
    const input = document.createElement("input");
    input.type = type;
    if (type === "month" || type === "date") {
      if (min) input.min = min;
      if (max) input.max = max;
    }
    input.name = name;
    input.id = name;
    if (value) input.value = value;
    if (placeholder) {
      input.placeholder = placeholder;
    }
    if (value) {
      input.value = value;
    }
    input.style.width = "100%";
    input.style.height = "30px";
    if (updateCompletionStatus) {
      input.addEventListener("input", () => {
        this.updateFormDataList();
        const formValues = this.getFormDataAsObject();
        this.updateCompletionStatus(formValues);
        this.updateMandatoryMessage(formValues);
      });
    }
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
   * @param {string} params.i18n - the key for the translation.
   * @returns {documentFragment} - a documentFragment containing the radio.
   */
  getRadio({ name, value, id, labelText, latestValue, i18n }) {
    const container = document.createElement("div");
    container.style.display = "flex";
    const radio = document.createElement("input");
    const label = document.createElement("label");
    label.style.fontSize = "0.9em";
    label.for = id;
    label.innerText = labelText;
    radio.type = "radio";
    radio.id = id;
    radio.name = name;
    radio.value = value;
    if (i18n) {
      setI18nAttribute({ element: label, attributeValue: i18n });
    }
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
  getTitle({ text, subtext = "", margin = "12px 0 0 0", i18n }) {
    const titleContainer = document.createElement("section");
    titleContainer.style.paddingBottom = "8px";
    const title = document.createElement("h5");
    title.style.margin = margin;
    title.style.backgroundColor = "#f1f1f1";
    title.style.padding = "2px";
    title.innerHTML = text;
    titleContainer.appendChild(title);
    if (subtext.length > 0) {
      const subtextElement = document.createElement("span");
      subtextElement.style.color = "grey";
      subtextElement.style.fontSize = "0.7em";
      subtextElement.innerText = subtext;
      subtextElement.style.paddingLeft = "2px";
      titleContainer.appendChild(subtextElement);
      title.style.marginBottom = 0;
    }
    if (i18n) {
      setI18nAttribute({ element: title, attributeValue: i18n });
    }
    return titleContainer;
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
    td.classList.add("popup__attributetable--title");
    setI18nAttribute({
      element: td,
      attributeValue: `popup.info.title.${layer.title.split(" ").join(".")}`
    });
    row.appendChild(td);
    table.appendChild(row);
    for (var i = 0; i < keys.length; i++) {
      const key = keys[i];
      if (hiddenAttributes.indexOf(key) !== -1) continue;
      const row = document.createElement("tr");
      const backgrundColor = i < 6 ? "#d6d6d6" : "#f0f0f0";
      row.style.backgroundColor = backgrundColor;
      const tdKey = document.createElement("td");
      setI18nAttribute({
        element: tdKey,
        attributeValue: `popup.info.${key}`
      });
      const tdVal = document.createElement("td");
      tdKey.classList.add("popup__attributetable--td");
      tdVal.classList.add("popup__attributetable--td");
      switch (key) {
        case "ereignisdatum":
          if (props[key] !== null) {
            tdVal.innerText = new Date(
              props[key].slice(0, props[key].length - 1)
            ).toLocaleDateString("de-ch");
          } else {
            if (props["validiert"]) {
              tdVal.innerText = "kA";
            }
          }
          break;
        case "validiert":
          row.style.color = "grey";
          row.style.fontStyle = "italic";
          tdVal.innerText =
            props[key] === null
              ? "nein"
              : new Date(props[key]).toLocaleDateString("de-ch");
          break;
        case "grund_veraenderung":
          // add a blankspace between the items,
          //otherwise the table owerflows the popup.d
          if (props[key]) {
            tdVal.innerText = props[key]
              .split(",")
              .map(string => string[0].toUpperCase() + string.slice(1))
              .join(", ");
          } else {
            if (props["validiert"]) {
              tdVal.innerText = "kA";
            }
          }
          break;
        case "flaeche_korrekt":
          if (props[key] === "ja") {
            tdVal.style.color = "#228b22";
          }
          if (props[key] === "nein") {
            tdVal.style.color = "#ff0000";
          }
          tdVal.innerText = props[key];
          break;
        case "flaeche_korrekt_bemerkung":
          if (!props[key]) continue;
          tdVal.innerText = props[key];
          tdVal.style.color = "#ff0000";
          break;
        default:
          tdVal.innerText = props[key];
          break;
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

  /*
   * changes to a particular tab in the edit popup.
   * @param {object} event - click event.
   * @param {string} tabid - id of the clicked tab.
   */
  switchTab(evt, tabid) {
    // Declare all variables
    let i, tabcontent, tablinks;

    // Get all elements with class="tabcontent" and hide them
    tabcontent = document.getElementsByClassName("tabcontent");
    for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
    }

    // Get all elements with class="tablinks" and remove the class "active"
    tablinks = document.getElementsByClassName("tablinks");
    for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
    }

    // Show the current tab, and add an "active" class to the button that opened the tab
    document.getElementById(tabid).style.display = "block";
    evt.currentTarget.className += " active";
  }

  /*
   * get meta information from feature
   * @param {object} feature - ol/Feature
   * @returns {object} - {layername, years, title, color, date}
   */
  getFeatureMetadata(feature) {
    const layername = feature.id_.split(".")[0];
    const splitted = layername.split("_");
    const years = `${splitted[splitted.length - 1]}-${
      splitted[splitted.length - 2]
    }`;
    const title = `Veränderung (Zeitraum ${years})`;
    const color = change_overlay_colors[layername];
    const date = feature.get("validiert");
    return {
      layername,
      years,
      title,
      color,
      date
    };
  }

  /*
   * creates the deckungsgrad radios.
   * @param {object} params - function parameter object.
   * @param {string} params.radiotitle - the title.
   * @param {string} params.radioname - name attribute of the radio input.
   * @returns {section Element} section - html section element with the radios.
   */
  getDeckungsgradRadios({ radiotitle, radioname }) {
    const latestValue = this.activeFeature.feature.get(radioname) || "kA";
    const section = document.createElement("section");
    const title = this.getTitle({
      text: `${radiotitle}`,
      subtext: "Veränderung geschätzt"
    });
    section.appendChild(title);
    const radioContainer = document.createElement("div");
    radioContainer.classList.add("popup__radiocontainer");
    section.appendChild(radioContainer);
    const radios = [
      { value: "0%" },
      { value: "25%" },
      { value: "50%" },
      { value: "75%" },
      { value: "100%" },
      { value: "kA" }
    ];
    radios.forEach(radio => {
      radioContainer.appendChild(
        this.getRadio({
          name: `${radioname}`,
          id: `${radioname}_${radio.value}`,
          value: radio.value,
          labelText: radio.value,
          latestValue
        })
      );
    });
    return section;
  }
}

export default Crowdsourcing;
