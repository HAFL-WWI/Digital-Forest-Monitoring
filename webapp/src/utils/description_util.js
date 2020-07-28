import { content, removeContent, createGrid } from "./main_util";
import descriptionContent from "./description_content";
const description_util = {
  controller: {
    /*
     * calls the necessary functions to display the projektbescchrieb.
     */
    init: () => {
      removeContent();
      description_util.controller.composeDescription();
    },
    composeDescription: () => {
      const grid = createGrid();
      const gridContainer = document.createElement("div");
      gridContainer.style.maxWidth = "1200px";
      gridContainer.style.margin = "0 auto";
      grid.appendChild(gridContainer);
      gridContainer.appendChild(description_util.view.getTitle());
      gridContainer.appendChild(description_util.view.getAuthors());
      gridContainer.appendChild(description_util.view.getHint());
      for (var i = 0; i < 6; i++) {
        gridContainer.appendChild(
          description_util.view.getBlock({
            title: descriptionContent.blocks[i].title,
            content: descriptionContent.blocks[i].content
          })
        );
      }
      content.appendChild(grid);
    }
  },
  view: {
    getWrapper: () => {
      const wrapper = document.createElement("div");
      wrapper.classList.add("mdc-layout-grid__cell");
      return wrapper;
    },
    getTitle: () => {
      const wrapper = description_util.view.getWrapper();
      const title = document.createElement("h1");
      title.innerText = descriptionContent.main_title;
      wrapper.appendChild(title);
      return wrapper;
    },
    getAuthors: () => {
      const wrapper = description_util.view.getWrapper();
      const authors = document.createElement("span");
      authors.style.fontSize = "12px";
      authors.innerText = descriptionContent.authors;
      wrapper.appendChild(authors);
      return wrapper;
    },
    getHint: () => {
      const wrapper = description_util.view.getWrapper();
      wrapper.innerHTML = descriptionContent.hint;
      return wrapper;
    },
    getBlock: ({ title, content }) => {
      const wrapper = description_util.view.getWrapper();
      const blockTitle = document.createElement("h2");
      blockTitle.innerText = title;
      const blockContent = document.createElement("div");
      blockContent.innerHTML = content;
      wrapper.appendChild(blockTitle);
      wrapper.appendChild(blockContent);
      return wrapper;
    }
  }
};

export default description_util;
