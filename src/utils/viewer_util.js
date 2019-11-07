const viewerUtil = {
  model: {
    /*
     * the element with the homepage content.
     */
    content: document.getElementsByClassName("content")[0]
  },
  controller: {
    /*
     * calls the necessary functions to display the viewer.
     */
    init: () => {
      viewerUtil.controller.removeContent();
      viewerUtil.controller.showViewer();
    },
    /*
     * removes 'old' content like homepage, services etc.
     */
    removeContent: () => {
      viewerUtil.model.content.innerHTML = "";
    },
    /*
     * displays the ol viewer
     */
    showViewer: () => {
      viewerUtil.model.content.appendChild(
        viewerUtil.view.getViewerContainer()
      );
    }
  },
  view: {
    /*
     * creates a full width/height container for the  viewer
     */
    getViewerContainer: () => {
      const viewerContainer = document.createElement("div");
      viewerContainer.style.width = "100vw";
      viewerContainer.style.height = "calc(100vh - 64px)";
      viewerContainer.style.backgroundColor = "yellowgreen";
      return viewerContainer;
    }
  }
};
export default viewerUtil;
