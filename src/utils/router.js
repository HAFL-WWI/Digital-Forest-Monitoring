import Navigo from "navigo";
import homepageUtil from "./homepage_util";
import viewerUtil from "./viewer_util";
export const router = new Navigo(null, false, "#");
export const initRouter = () => {
  router
    .on({
      "/": () => {
        console.log("display homepage");
        homepageUtil.controller.init();
      },
      "/viewer": (params, query) => {
        console.log("show the viewer");
        console.log(params);
        console.log(query);
        viewerUtil.controller.init();
      },
      "/services": () => {
        console.log("service route");
      }
    })
    .resolve();

  router.notFound(() => homepageUtil.controller.createHomepageCards());
};
