import { Map, View } from "ol";
import { defaults as defaultControls, Control } from "ol/control";
import { MDCList } from "@material/list";
import "ol/ol.css";
import { orthoBasemap, swBasemap, vegetationBasemap } from "./basemap_util";
import { debounce, searchResults, displayGeojson } from "./main_util";
import { textField } from "./init";
import BasemapControl from "./BasemapControl";
import VHMControl from "./VHMControl";
import ViewerControl from "./ViewerControl";
import { updateUrl, getQueryParams, removeParam } from "./url_util";
import GpsPosition from "./positionUtil";

const viewerUtil = {
  model: {
    /*
     * the element with the content below the app bar.
     */
    content: document.getElementsByClassName("content")[0],
    searchResultsList: document.querySelector(".mdc-list")
  },
  controller: {
    /*
     * calls the necessary functions to display the viewer.
     * @param {object} params.
     * @param {string} params.title - the title/name of the viewer.
     */
    init: ({ title }) => {
      viewerUtil.controller.removeContent();
      viewerUtil.controller.createContainer();
      viewerUtil.controller.showViewer(title);
      viewerUtil.controller.attachEventListeners();
      viewerUtil.model.searchList = new MDCList(
        document.querySelector(".mdc-list")
      );
      viewerUtil.model.searchList.singleSelection = true;
      // make the search input value equal the focus element
      viewerUtil.model.searchList.listen("focusin", e => {
        textField.value = e.target.innerText;
      });
      // show the geometry on the map if a list item gets selected
      viewerUtil.model.searchList.listen("MDCList:action", () => {
        viewerUtil.controller.showSearchGeometry();
        viewerUtil.controller.closeSearchResults(searchResults);
      });
    },
    /*
     * displays the geometry from the currently selected search result on the map
     */
    showSearchGeometry: () => {
      const selectedIndex = viewerUtil.model.searchList.selectedIndex;
      const selectedElement =
        viewerUtil.model.searchList.listElements[selectedIndex];
      if (selectedElement) {
        displayGeojson({
          geojson: JSON.parse(selectedElement.dataset.geojson),
          map: viewerUtil.model.map
        });
      }
    },
    /*
     * removes 'old' content like homepage, services etc.
     */
    removeContent: () => {
      viewerUtil.model.content.innerHTML = "";
    },
    /*
     * remove all the non basemap layers from map
     * @returns {array} remaining (basemap) layers
     */
    removeOverlayLayers: () => {
      const currentLayers = viewerUtil.model.map.getLayers().getArray();
      for (var i = currentLayers.length - 1; i > 2; i--) {
        if (currentLayers[i].name !== "gps") {
          viewerUtil.model.map.removeLayer(currentLayers[i]);
        }
      }
      return currentLayers;
    },
    /*
     * displays the ol viewer
     */
    createContainer: () => {
      viewerUtil.model.viewerContainer = viewerUtil.view.getViewerContainer();
      viewerUtil.model.content.appendChild(viewerUtil.model.viewerContainer);
    },
    /*
     * display the ol viewer inside the viewer container
     * @param {string} title - the title to display on top of the layer control.
     */
    showViewer: title => {
      const urlParams = getQueryParams();
      // we only have to create a new map object, if no one exists.
      if (viewerUtil.model.map === undefined) {
        viewerUtil.model.map = new Map({
          view: new View({
            center: [urlParams.x || 829300, urlParams.y || 5933555], //defaults to Bern
            zoom: urlParams.zoom || 13,
            minZoom: 9,
            maxZoom: 20,
            rotation: parseFloat(urlParams.rotation) || 0
          }),
          layers: [orthoBasemap, swBasemap, vegetationBasemap],
          target: "map",
          controls: defaultControls({
            attributionOptions: { collapsible: false }
          })
        });
        const basemapSwitch = new BasemapControl(
          viewerUtil.model.map,
          urlParams.basemap || "Orthofoto"
        );
        const vhmControl = new VHMControl(
          viewerUtil.model.map,
          urlParams.vhm ? true : false
        );
        viewerUtil.model.map.addControl(basemapSwitch.createBasemapControl());
        viewerUtil.model.map.addControl(vhmControl.createVHMControl());
        // add the positioning control
        viewerUtil.model.positioning = new GpsPosition(viewerUtil.model.map);
        const positioning = new Control({
          element: viewerUtil.model.positioning.getPositionElement()
        });
        viewerUtil.model.map.addControl(positioning);
      } else {
        // if we allready have a map object, only set the target.
        viewerUtil.model.map.setTarget(viewerUtil.model.viewerContainer);
        viewerUtil.controller.removeOverlayLayers();
        viewerUtil.view.removeViewerControls();
      }
      const viewerControl = new ViewerControl({
        map: viewerUtil.model.map,
        title,
        urlParams
      });
      viewerUtil.model.viewerControl = viewerControl.createControl({
        type: title
      });
      viewerUtil.model.map.addControl(viewerUtil.model.viewerControl);
      viewerUtil.model.map.addEventListener("click", e => console.log(e));
    },
    /*
     * close the search results and set the correct z-index in order for paning/zooming to work as expected.
     * @param {domElement} searchResults - the search results container.
     * @returns {domElement} searchResults - the search results container or false in case of failure.
     */
    closeSearchResults: searchResults => {
      if (searchResults) {
        searchResults.style.transform = "scale(1,0)";
        searchResults.style.zIndex = -1;
        return searchResults;
      }
      return false;
    },
    /*
     * performs the places search
     * @param {object} event - textfield input event
     * @returns {object} promise - a promise with searchresults
     */
    performSearch: debounce(e => {
      viewerUtil.controller.closeSearchResults(searchResults);
      const searchString = e.target.value;
      viewerUtil.model.searchResultsList.innerHTML = "";
      if (searchString.length > 1) {
        searchResults.style.zIndex = 5;
        searchResults.style.transform = "scale(1)";
        const url = `https://api3.geo.admin.ch/rest/services/api/SearchServer?searchText=${e.target.value}&type=locations&limit=50&sr=3857&geometryFormat=geojson`;
        const request = new XMLHttpRequest();
        request.open("GET", url, true);
        request.onload = () => {
          if (request.status >= 500) {
            viewerUtil.model.searchResultsList.innerHTML = `<div style="padding:12px">Sorry, es konnten keine Resultate gefunden werden....</div>`;
            return;
          }
          const featureCollection = JSON.parse(request.responseText);
          featureCollection.features.forEach((feature, index) => {
            const listItem = document.createElement("li");
            // add the geojson as a data attribute
            listItem.setAttribute("data-geojson", JSON.stringify(feature));
            const listItemText = document.createElement("span");
            listItem.classList.add("mdc-list-item");
            listItemText.classList.add("mdc-list-item__text");
            if (index === 0) {
              listItem.tabIndex = index;
            }
            listItemText.innerHTML = `${feature.properties.label}`;
            listItem.appendChild(listItemText);
            viewerUtil.model.searchResultsList.appendChild(listItem);
          });
          viewerUtil.model.searchList.layout();
        };
        request.onerror = () => {
          viewerUtil.model.searchResultsList.innerHTML = `<div style="padding:12px">Es gab einen Fehler bei der Suchanfrage....</div>`;
        };
        request.send();
      }
    }, 250),
    attachEventListeners: () => {
      viewerUtil.model.map.on("moveend", event => {
        const view = event.map.getView();
        const center = view.getCenter();
        const rotation = parseFloat(view.getRotation()).toFixed(6);
        const queryParams = {
          zoom: parseFloat(view.getZoom()).toFixed(4),
          x: parseInt(center[0]),
          y: parseInt(center[1])
        };
        if (rotation > 0) {
          queryParams.rotation = rotation;
        } else {
          removeParam("rotation");
        }
        updateUrl(queryParams);
      });
    }
  },
  view: {
    /*
     * creates a full width/height container for the  viewer
     * @returns {DomElement} - a div with the right styles to be used as the map.
     */
    getViewerContainer: () => {
      const viewerContainer = document.createElement("div");
      viewerContainer.id = "map";
      return viewerContainer;
    },
    /*
     * remove the viewer controls from the map object and the dom
     */
    removeViewerControls() {
      if (viewerUtil.model.viewerControl) {
        viewerUtil.model.map.removeControl(viewerUtil.model.viewerControl);
      }
    }
  }
};
export default viewerUtil;
