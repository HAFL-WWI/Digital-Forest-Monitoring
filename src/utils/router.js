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
      "/viewer": (params, query) => {
        console.log(params);
        console.log(query);
        viewerUtil.controller.init();
        changeTitle("Jährliche Veränderung");
      },
      "/services": () => {
        servicesUtil.controller.init();
        changeTitle("Geodienste");
      }
    })
    .resolve();

  router.notFound(() => homepageUtil.controller.createHomepageCards());
};
