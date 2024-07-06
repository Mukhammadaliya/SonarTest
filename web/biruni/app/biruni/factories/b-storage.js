biruni.factory('bStorage', function () {
  function supportsLocalStorage() {
    return ('localStorage' in window) && window['localStorage'] !== null;
  }

  function save(key, val) {
    if (!supportsLocalStorage()) {
      return;
    }
    if (val) {
      localStorage[key] = val;
    } else {
      delete localStorage[key];
    }
  }

  function load(key) {
    if (!supportsLocalStorage()) {
      return null;
    }
    return localStorage[key];
  }

  function loadJSON(key) {
    try {
      return JSON.parse(load(key)) ?? {};
    } catch (e) {
      return {};
    }
  }

  function saveJSON(key, val) {
    save(key, JSON.stringify(val));
  }

  function text(key, val) {
    if (arguments.length > 1) {
      save(key, val);
    } else {
      return load(key);
    }
  }

  function json(key, val) {
    if (arguments.length > 1) {
      saveJSON(key, val);
    } else {
      return loadJSON(key);
    }
  }

  return {
    text : text,
    json : json
  };
});
