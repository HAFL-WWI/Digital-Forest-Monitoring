import Navigo from "navigo";
import homepageUtil from "./homepage_util";
import viewerUtil from "./viewer_util";
import servicesUtil from "./services_util";
import { changeTitle, setTitle, getTitle } from "./main_util";
export const router = new Navigo(null, false, "#");
export const initRouter = () => {
  router
    .on({
      "/": () => {
        homepageUtil.controller.init();
        setTitle(getTitle());
      },
      "/veraenderung": (params, query) => {
        console.log(params);
        console.log(query);
        viewerUtil.controller.init();
        changeTitle("Jährliche Veränderung");
      },
      "/stoerungen": () => {
        changeTitle("Natürliche Störungen");
        const content = document.getElementsByClassName("content")[0];
        content.innerHTML =
          "<div style='padding:12px'><h1>Dieser Viewer befindet sich in Entwicklung</h1><h3>Vielen Dank für Ihr Verständnis</h3></div>";
      },
      "/services": () => {
        servicesUtil.controller.init();
        changeTitle("Geodienste");
      }
    })
    .resolve();

  router.notFound(() => homepageUtil.controller.createHomepageCards());
  //register the click event listener for the home button
  document.querySelector("#home-button").addEventListener("click", () => {
    router.navigate("/");
  });
};
