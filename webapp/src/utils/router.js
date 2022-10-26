import Navigo from "navigo";
import homepageUtil from "./homepage_util";
import viewerUtil from "./viewer_util";
import servicesUtil from "./services_util";
import {
  hideTitle,
  positionSearchResultContainer,
  closeSidebar,
  sidebar,
  addVideoLink,
  removeVideoLink,
  updateTitle,
  hideHomeButton,
  showHomeButton
} from "./main_util";
export const router = new Navigo(null, false, "#");
export const initRouter = () => {
  router
    .on({
      "/": () => {
        textField.style.display = "none";
        homepageUtil.controller.init();
        updateTitle();
        removeVideoLink();
        hideHomeButton();
      },
      "/veraenderung": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        showHomeButton();
        textField.style.display = "inline-flex";
        addVideoLink({
          title: "jährliche Veränderung",
          videoId: "mYK2KJqgrhM"
        });
        viewerUtil.controller.init({ title: "Jährliche Veränderung" });
        positionSearchResultContainer();
      },
      "/stoerungen": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        showHomeButton();
        textField.style.display = "inline-flex";
        addVideoLink({ title: "natürliche Störungen", videoId: "aamvbhKXoNU" });
        viewerUtil.controller.init({ title: "Natürliche Störungen" });
        positionSearchResultContainer();
      },
      "/vitalitaet": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        showHomeButton();
        textField.style.display = "inline-flex";
        addVideoLink({
          title: "Hinweiskarten zur Vitalität",
          videoId: "wraBOBSfcdk"
        });
        viewerUtil.controller.init({ title: "Vitalität der Wälder" });
        positionSearchResultContainer();
      },
      "/verjuengung": () => {
        // we dont't want a short sidebar transition on startup
        // that's why we add it here, after the app has loaded.
        sidebar.style.transition = "transform 0.3s";
        hideTitle();
        showHomeButton();
        textField.style.display = "inline-flex";
        viewerUtil.controller.init({ title: "Hinweiskarten Verjüngung" });
        positionSearchResultContainer();
      },
      "/services": () => {
        removeVideoLink();
        showHomeButton();
        servicesUtil.controller.init();
        updateTitle();
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
