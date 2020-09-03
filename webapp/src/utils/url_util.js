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
