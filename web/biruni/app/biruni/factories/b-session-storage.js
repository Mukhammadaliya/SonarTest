biruni.factory('bSessionStorage', function () {
  function supportsSessionStorage() {
    return ('sessionStorage' in window) && window['sessionStorage'] !== null;
  }

  function set(key, val) {
    if (!supportsSessionStorage()) {
      return;
    }
    window.sessionStorage.setItem(key, val);
  }

  function get(item) {
    if (!supportsSessionStorage()) {
      return;
    }
    return window.sessionStorage.getItem(item);
  }

  function remove(item) {
    if (!supportsSessionStorage()) {
      return;
    }
    window.sessionStorage.removeItem(item);
  }

  return {
    set    : set,
    get    : get,
    remove : remove
  };
});