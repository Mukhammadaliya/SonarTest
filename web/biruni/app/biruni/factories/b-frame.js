biruni.factory('bFrame', function (bConfig, $location, bPage) {
  function parseUrl() {
    let url = $location.$$path, param = angular.copy($location.$$search), type, path, pure_param;
    if (url) {
      if (url.startsWith("/!")) {
        let ind = url.indexOf("/", 1);
        if (ind > 0) {
          let hash = parseInt(url.substring(2, ind), 36).toString();
          if (hash.length > 7) {
            type = "ready";
            param["-project_hash"] = hash.substr(5, 2);
            param["-filial_id"] = hash.substr(7);
          }
          path = url.substr(ind);
        }
      } else if (_.has(param, '-filial_id') && _.has(param, '-project_code')) {
        type = "normalize";
        path = url;
      }
    } else type = "redirect";

    pure_param = angular.copy(param);
    // remove unnecessary keys
    delete pure_param["-mobile"];
    delete pure_param["-filial_id"];
    delete pure_param["-project_hash"];
    delete pure_param["-project_code"];

    return {
      type: type,
      url: url,
      path: path,
      param: param,
      pure_param: pure_param
    };
  }

  function refreshIds() {
    f.pageIds = [];
    for (var i = 0; i < f.pages.length; i++) {
      if (i === f.pages.length - 1 || f.pages[i].saved) {
        f.pageIds.push(f.pages[i].id);
      }
    }
  }

  function onLocationChange(parsed_url) {
    let i = _.findIndex(f.pages, { hash: parsed_url.url });
    if (i > -1) {
      let p = f.pages[i];
      if (f.pages.length !== i + 1 && p.saved === false) {
        p.reload();
      }
      f.pages = _.first(f.pages, i + 1);
      p.qLoaded.promise.then(function () {
        p.saved = false;
        if (_.isFunction(p.onRestart)) {
          let rd = p.restartData;
          p.restartData = undefined;
          p.onRestart(rd);
        }
        document.title = p.title;
      });
    } else {
      f.pages = [bPage(parsed_url.url, parsed_url.path, parsed_url.pure_param || {}, {})];
    }

    refreshIds();
  }

  function open(path, param, fn, xparam, pure) {
    var p = _.last(f.pages);
    if (p && _.isFunction(fn)) {
      p.onRestart = _.once(fn);
    }
    var url = (pure ? '' : bConfig.pathPrefix()) + path;
    f.pages.push(bPage(url, path, param || {}, xparam || {}));
    $location.path(url);
    $location.search(param || {});
  }

  function openDialog(path, param, fn, xparam, pure) {
    _.last(f.pages).saved = true;
    open(path, param, fn, xparam, pure);
  }

  function openReplace(path, param, xparam, pure) {
    let subpage;
    if (f.pages.length > 0) {
      subpage = Object.values(f.pages[f.pages.length - 1].subpages).find(sb=>sb.path == path);
      if(!subpage){
        f.pages.pop();
      }
    }
    if (subpage) {
      subpage.run(path, param, xparam);
    } else {
      open(path, param, null, xparam, pure);
      $location.replace();
    }
  }

  function openClear(path, param, xparam, pure) {
    f.pages = [];
    refreshIds();
    open(path, param, null, xparam, pure);
  }

  function openWindow(uri, param) {
    var data = _.defaults({}, param || {});
    var auths = bConfig.auths();
    for (var k in auths) {
      data['-' + k] = auths[k];
    }
    window.open('b' + uri + '?' + $.param(data, true));
  }

  function close(data) {
    if (f.pages.length > 1) {
      var p = f.pages[f.pages.length - 2];
      p.restartData = data;
    }
    window.history.back();
  }

  function pageTitle() {
    if (f.pages.length > 0) {
      return f.pages[f.pages.length - 1].title;
    }
    return '';
  }

  function findPage(pageId) {
    return _.findWhere(f.pages, {
      id : pageId
    });
  }

  function breadcrumbPages() {
    return _.initial(f.pages).reverse();
  }

  function formSiblings() {
    return _.last(f.pages).siblings || [];
  }

  var f = {
    pages : [],
    pageIds : [],
    parseUrl: parseUrl,
    refreshIds: refreshIds,
    open : open,
    openDialog : openDialog,
    openReplace : openReplace,
    openClear : openClear,
    openWindow: openWindow,
    close : close,
    onLocationChange : onLocationChange,
    pageTitle : pageTitle,
    setFavorite: _.noop,
    findPage : findPage,
    breadcrumbPages : breadcrumbPages,
    formSiblings : formSiblings
  };

  return f;
});
