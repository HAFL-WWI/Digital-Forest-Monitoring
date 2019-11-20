import Navigo from "navigo";
import homepageUtil from "./homepage_util";
import viewerUtil from "./viewer_util";
import servicesUtil from "./services_util";
import {
  setTitle,
  getTitle,
  showTitle,
  hideTitle,
  positionSearchResultContainer
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
        hideTitle();
        textField.style.display = "inline-flex";
        viewerUtil.controller.init({ title: "Jährliche Veränderung" });
        // position the search result container
        positionSearchResultContainer();
      },
      "/stoerungen": () => {
        textField.style.display = "none";
        setTitle("Natürliche Störungen");
        const content = document.getElementsByClassName("content")[0];
        content.innerHTML =
          "<div style='padding:12px'><h1>Dieser Viewer befindet sich in Entwicklung</h1><h3>Vielen Dank für Ihr Verständnis</h3></div>";
      },
      "/services": () => {
        servicesUtil.controller.init();
        setTitle("Geodienste");
      }
    })
    .resolve();

  router.notFound(() => homepageUtil.controller.createHomepageCards());
  //register the click event listener for the home button
  document.querySelector("#home-button").addEventListener("click", () => {
    router.navigate("/");
  });
};

const textField = document.querySelector(".mdc-text-field");
