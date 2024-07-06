biruni.factory('bRequire', function($q, bAssets, bAlert) {
  var assets = {};
  var lazyPromises = {};

  _.each(bAssets, (val, key) => {
    assets[key.toLowerCase()] = val;
  });

  function createScript(src) {
    var script = document.createElement("script");

    script.src = src;

    return script;
  }

  function createLink(href) {
    var link = document.createElement("link");

    link.href = href;
    link.rel = "stylesheet";
    link.type = "text/css"

    return link;
  }

  function lazyLoad(src, type) {
    if (_.has(lazyPromises, src)) return lazyPromises[src];

    var defer = $q.defer();

    var elem = type == "script"? createScript(src): createLink(src);
    elem.async = false;
    elem.onload = ()=> defer.resolve();
    elem.onerror = ()=> defer.reject(`error loading script ${src}`);

    document.head.appendChild(elem);

    return lazyPromises[src] = defer.promise;
  }

  function load(...arg) {
    return $q.all(
    _.chain(arg)
     .map(x=> x.toLowerCase())
     .reject(x=> {
        if (!_.has(assets, x)) {
          console.error(`this asset is not included: asset=${x}`);
          return true;
        }
        return false;
      })
     .reduce((promises, r)=> {
        let x = assets[r];

        if (x.css) {
          if (!_.isArray(x.css)) x.css = [x.css];
          _.each(x.css, e=> promises.push(lazyLoad(e, "link")));
        }

        if (x.script) {
          if (!_.isArray(x.script)) x.script = [x.script];
          _.each(x.script, e=> promises.push(lazyLoad(e, "script")));
        }

        return promises;
     }, [])
     .flatten()
     .value()).then(null, bAlert.open);
  }

  return {
    load: load
  }
});