import queryString from "query-string";

/*
 * gets the url query parameters as js object.
 */
export const getQueryParams = () => {
  return queryString.parse(window.location.search);
};

/*
 * removes a certain property from the url params.
 * @param {string} key - the object key to remove.
 * @returns {object} - the updated params.
 */
export const removeParam = param => {
  const params = getQueryParams();
  if (params[param]) {
    delete params[param];
    replaceUrl(params);
  }
  return params;
};

/*
 * updates the query parameters of the url
 * @param {object} params an object containing key:value pairs of search params.
 * @returns {string} the search params section of the url.
 */
export const updateUrl = params => {
  if (params) {
    const splittedUrl = window.location.href.split("?");
    const parsedParams = queryString.parse(window.location.search);
    //update the parsed params with the parameter values
    const newParams = { ...parsedParams, ...params };
    const stringified = queryString.stringify(newParams);
    window.history.replaceState(
      newParams,
      document.title,
      splittedUrl[0] + "?" + stringified
    );
    return window.location.search;
  }
  // when no params are provided return the current url params as a string
  return window.location.search;
};

/*
 * completely replaces the query parameters of the url.
 * @param {object} params an object containing key:value pairs of search params.
 * @returns {string} the search params section of the url.
 */
const replaceUrl = params => {
  if (params) {
    const splittedUrl = window.location.href.split("?");
    const stringified = queryString.stringify(params);
    window.history.replaceState(
      params,
      document.title,
      splittedUrl[0] + "?" + stringified
    );
    return window.location.search;
  }
  // when no params are provided return the current url params as a string
  return window.location.search;
};

/*
 * add a new layer to the url query parameter, including visibility and transpareny
 * @param {object} layer - {name: layername, visibility: true/false, transparency: value between 0 and 1}
 * @returns {string} the updatet url
 */
export const addLayerToUrl = layer => {
  // check if there is already a layer parameter in the url
  const currentParams = getQueryParams();
  // if it's the first layer to add
  if (!currentParams.layers) {
    currentParams.layers = layer.layername.toString();
    currentParams.visibility = layer.visible.toString();
    currentParams.opacity = layer.opacity.toString();
    // for nbr layers
    if (layer.time) {
      currentParams.time = layer.time.substring(0, 10);
    }
    return updateUrl(currentParams);
  }
  // in case there are already layers loaded
  else {
    const layers = currentParams.layers.split(",");
    if (layers.indexOf(layer.layername) !== -1) {
      return;
    }
    layers.unshift(layer.layername);
    const visibilities = currentParams.visibility.split(",");
    visibilities.unshift(layer.visible.toString());
    const opacities = currentParams.opacity.split(",");
    opacities.unshift(layer.opacity.toString());
    const newParams = {
      layers: layers.join(","),
      visibility: visibilities.join(","),
      opacity: opacities.join(",")
    };
    if (layer.time) {
      console.log("update the time attribute...");
      newParams.time = layer.time.substring(0, 10);
    }
    return updateUrl(newParams);
  }
};

/*
 * remove a layer from the url query parameter, including visibility and transpareny
 * @param {object} layer - {name: layername}
 * @returns {string} the updatet url or false in case of failure.
 */
export const removeLayerFromUrl = layer => {
  const currentParams = getQueryParams();
  if (!layer || !currentParams.layers) {
    return false;
  }
  const layers = currentParams.layers.split(",");
  const visibilities = currentParams.visibility.split(",");
  const opacities = currentParams.opacity.split(",");
  // search for the array index of the particular layer
  const index = layers.indexOf(layer.layername);
  if (index !== -1) {
    if (layers.length === 1) {
      // delete the entries for layers, visibility and opacity
      delete currentParams.layers;
      delete currentParams.opacity;
      delete currentParams.visibility;
      delete currentParams.time;
      return replaceUrl(currentParams);
    } else {
      // remove the values from the url string
      layers.splice(index, 1);
      visibilities.splice(index, 1);
      opacities.splice(index, 1);
      return updateUrl({
        layers: layers.join(","),
        visibility: visibilities.join(","),
        opacity: opacities.join(",")
      });
    }
  }
};

/*
 * updates the visibility and/or opacitiy url params of a layer
 * @param {object} layer - {name: layername, opacity:0-1, visibility: true/false}
 * @returns {string} the updatet url or false in case of failure.
 */
export const updateUrlVisibilityOpacity = layer => {
  if (!layer) {
    return false;
  }
  const currentParams = getQueryParams();
  let { layers, visibility, opacity } = currentParams; //url strings
  const layersArr = layers.split(",");
  if (!layers || !Array.isArray(layersArr)) {
    return false;
  }

  let visibilityArr = [];
  let opacityArr = [];
  if (visibility) {
    visibilityArr = visibility.split(",");
  }
  if (opacity) {
    opacityArr = opacity.split(",");
  }
  //update visibility and opacity for the layer
  //and every layer that has no value for it in the url
  layersArr.forEach((name, i) => {
    if (name === layer.layername) {
      visibilityArr[i] = layer.visible.toString();
      opacityArr[i] = parseFloat(layer.opacity.toString()).toFixed(1);
    } else {
      if (!visibilityArr[i]) {
        visibilityArr[i] = "true";
      }
      if (!opacityArr[i]) {
        opacityArr[i] = 1.0;
      }
    }
  });
  return updateUrl({
    opacity: opacityArr.join(","),
    visibility: visibilityArr.join(",")
  });
};
