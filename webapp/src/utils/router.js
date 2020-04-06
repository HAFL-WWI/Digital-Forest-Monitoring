import Navigo from "navigo";
import homepageUtil from "./homepage_util";
import viewerUtil from "./viewer_util";
import servicesUtil from "./services_util";
import {
  setTitle,
  getTitle,
  showTitle,
  hideTitle,
  positionSearchResultContainer,
  closeSidebar,
  sidebar
} from "./main_util";
export const router = new Navigo(null, false, "#");
export const initRouter = () => {
  router
    .on({
      "/": () => {
        textField.style.display = "none";
        homepageUtil.controller.init();
        setTitle(getTitle());
        showTitle();
      },
      "/veraenderung": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        textField.style.display = "inline-flex";
        viewerUtil.controller.init({ title: "Jährliche Veränderung" });
        positionSearchResultContainer();
      },
      "/stoerungen": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        textField.style.display = "inline-flex";
        viewerUtil.controller.init({ title: "Natürliche Störungen" });
        positionSearchResultContainer();
      },
      "/vitalitaet": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        textField.style.display = "inline-flex";
        viewerUtil.controller.init({ title: "Vitalität der Wälder" });
        positionSearchResultContainer();
      },
      "/services": () => {
        servicesUtil.controller.init();
        setTitle("Geodienste");
      }
    })
    .resolve();

  router.notFound(() => homepageUtil.controller.createHomepageCards());
  /* register the click event listener for the home button
   * this event listener is currently in this place, because here it has access to the router.
   * normally this belongs to init.js and will probably be moved in the future
   */
  document.querySelector("#home-button").addEventListener("click", () => {
    closeSidebar();
    router.navigate("/");
  });
};

const textField = document.querySelector(".mdc-text-field");
