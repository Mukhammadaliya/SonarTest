biruni.factory('bBasePage', function ($q, $http, $compile, $injector, bHttp, bQuery, bGridScroll, bGrid, bAlert, bConfirm, bConfig, bRequire, bRoutes, bPgGrid, bHotkey, bPreview, bFaceCropper) {

  function makeGridApi(grid) {

    function enable() {
      grid.g.enabled = true;
    }

    function disable() {
      grid.g.enabled = false;
    }

    return {
      enable: enable,
      disable: disable,
      fetch: grid.fetch,
      asHtml: grid.asHtml
    };
  }

  function makeApi(page) {

    function showPageBar(val) {
      page.show_bar = val;
    }

    function setTitle(title) {
      return arguments.length ? page.title = title : page.title;
    }

    function setRequire(...arg) {
      page.requires = _.chain(arg).flatten().compact().uniq().value();
    }

    function setInit(initFn) {
      page.onInit = initFn;
    }

    function setCtrl(ctrlFn) {
      page.onCtrl = ctrlFn;
    }

    function formValid(form) {
      form.$setSubmitted();
      return form.$valid;
    }

    function setUntouched(form) {
      form.$setPristine();
      form.$setUntouched();
    }

    function isDialog() {
      return page.is_dialog;
    }

    function isInit() {
      return page.is_init;
    }

    function isFirst() {
      return page.is_first;
    }

    function emit(action, data) {
      if (_.isFunction(page.emitCallbacks[action])) {
        page.emitCallbacks[action](data);
      }
    }

    function on(action, callback) {
      if (_.isFunction(callback)) {
        page.broadcastCallbacks[action] = callback;
      }
    }

    function makeUrl(name, data) {
      var r = 'b' + page.path;
      if (name) {
        r += ':' + name;
      }
      data = _.defaults({}, data || {});
      var auths = bConfig.auths();
      for (var k in auths) {
        data['-' + k] = auths[k];
      }
      return r + '?' + $.param(data, true);
    }

    function makeUploadParamsUrl(name, data) {
      return bHttp.postData(bRoutes.UPLOAD_URL_PARAMS, data).then(
        (result) =>  {
          return makeUrl(name, {sha: result.data});
        },
        (error)=> {
          bAlert.open(error);
          return "";
        }
      );
    }

    function getGrid(name) {
      return makeGridApi(page.grid(name));
    }

    function isInFullscreen() {
      if (document.fullscreenElement) {
        return true;
      } else if (document.webkitFullscreenElement) {
        return true;
      } else return !!document.mozFullScreenElement;
    }

    function launchFullscreen(elem) {
      if (elem.requestFullScreen) {
        elem.requestFullScreen();
      } else if (elem.mozRequestFullScreen) {
        elem.mozRequestFullScreen();
      } else if (elem.webkitRequestFullScreen) {
        elem.webkitRequestFullScreen();
      }
    }

    function cancelFullscreen() {
      if (document.cancelFullScreen) {
        document.cancelFullScreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.webkitCancelFullScreen) {
        document.webkitCancelFullScreen();
      }
    }

    function saveFile(file) {
      return bHttp.postFileAlone(file).then(result => {
        return {
          sha: result.data,
          name: file.name,
          size: file.size,
          type: file.type
        };
      });
    }

    function loadImage(sha, width, height) {
      let url = bRoutes.LOAD_IMAGE + '&sha=' + sha;
      let width_num = +width;
      let height_num = +height;
      // skips if width and height are not specified
      if (width_num >= 10 && height_num >= 10) {
        url += `&width=${ width_num }&height=${ height_num }`;
      }
      return url;
    }

    function loadImageSmall(sha) {
      return bRoutes.LOAD_IMAGE + '&sha=' + sha + "&type=S";
    }

    function loadImageMedium(sha) {
      return bRoutes.LOAD_IMAGE + '&sha=' + sha + "&type=M";
    }

    function loadImageLarge(sha) {
      return bRoutes.LOAD_IMAGE + '&sha=' + sha + "&type=L";
    }

    function loadFile(sha) {
      return bRoutes.LOAD_FILE + "?sha=" + sha;
    }

    function downloadFile(sha) {
      return bRoutes.DOWNLOAD_FILE + "?sha=" + sha;
    }

    function prefClear(callback, unblock) {
      bConfirm.confirm(bConfig.langs.pref_clear, function() {
        callback = callback ? callback : page.reload;
        $http.post(bRoutes.PREFERENCES_CLEAR, { form: page.path }, { unblock: !!unblock }).then(callback);
      });
    }

    return {
      id: () => page.id,
      require: setRequire,
      init: setInit,
      ctrl: setCtrl,
      title: setTitle,
      header: showPageBar,
      open: page.open,
      openDialog: page.openDialog,
      openReplace: page.openReplace,
      openClear: page.openClear,
      close: page.close,
      reload: page.run,
      bindHotkey: page.bindHotkey,
      previewFile: page.previewFile,
      faceCropper: page.faceCropper,
      post: page.post,
      query: page.query,
      grid: getGrid,
      pgGrid: page.pgGrid,
      dropzone: page.dropzone,
      getMap: page.getMap,
      storage: page.storage,
      valid: formValid,
      untouch: setUntouched,
      alert: bAlert.open,
      confirm: bConfirm.confirm,
      isDialog: isDialog,
      isInit: isInit,
      isFirst: isFirst,
      emit: emit,
      on: on,
      url: makeUrl,
      uploadParamsUrl: makeUploadParamsUrl,
      isInFullscreen: isInFullscreen,
      launchFullscreen: launchFullscreen,
      cancelFullscreen: cancelFullscreen,
      saveFile: saveFile,
      loadImage: loadImage,
      loadImageSmall: loadImageSmall,
      loadImageMedium: loadImageMedium,
      loadImageLarge: loadImageLarge,
      loadFile: loadFile,
      downloadFile: downloadFile,
      prefClear: prefClear
    };
  }

  function justifyName(name, prefix) {
    if (/^[:$]?[A-Za-z0-9_]+$/.test(name)) {
      if (/^[:$]/.test(name)) {
        return name;
      } else {
        return prefix + name;
      }
    } else {
      throw 'Invalid action name';
    }
  }

  function showElem(elem) {
    elem.find('[data-toggle="popover"]').popover();
    elem.show();
  }

  function formUrl(path, param) {
    var r = angular.copy(param);
    return path + '?' + $.param(r);
  }

  function notImplemented(key) {
    return function() {
      throw `${key} function is not implemented`;
    }
  }

  function Page(path, param, xparam) {
    var t = this;
    t.path = path;
    t.param = param;
    t.xparam = xparam;

    t.queries = {};
    t.gridScrolls = {};
    t.grids = {};
    t.pgGrids = {};
    t.maps = {};
    t.hotkeys = {};
    t.storageValue = {};

    t.emitCallbacks = {};
    t.broadcastCallbacks = {};

    //@overide functions
    t.openFunc        = notImplemented("open");
    t.openDialogFunc  = notImplemented("openDialog");
    t.openReplaceFunc = notImplemented("openReplace");
    t.openClearFunc   = notImplemented("openClear");
    t.closeFunc       = notImplemented("close");
    t.runFunc         = notImplemented("run");

    // open pages
    t.open        = function(...args) { t.openFunc(...args); }
    t.openDialog  = function(...args) { t.openDialogFunc(...args); }
    t.openReplace = function(...args) { t.openReplaceFunc(...args); }
    t.openClear   = function(...args) { t.openClearFunc(...args); }
    t.close       = function(...args) { t.closeFunc(...args); }
    t.run         = function(...args) { t.runFunc(...args); }

    t.addApi      = addApi;
    t.setDialog   = setDialog;
    t.setFirst    = setFirst;
    t.setTitle    = setTitle;
    t.setFavorite = _.noop;

    t.bindHotkey = bindHotkey;
    t.previewFile = previewFile;
    t.faceCropper = faceCropper;
    t.query = query;
    t.post = post;
    t.gridScroll = gridScroll;
    t.grid = grid;
    t.pgGrid = pgGrid;
    t.dropzone = dropzone;
    t.getMap = getMap;
    t.broadcast = broadcast;
    t.storage = storage;
    t.on = on;

    t.reload = reload;
    t.translate = translate;

    t.pureLangs = {};

    t.langs = {};
    t.langsNew = {};
    t.langsSuppress = [];

    t.is_init = true;
    t.is_first = true;
    t.show_bar = true;
    t.is_dialog = false;

    t.api = makeApi(t);
    t.api.prefClear.title = bConfig.langs.pref_clear;
    t.api.close.title = bConfig.langs.close;

    function addApi(api_key, func) {
      t.api[api_key] = func;
    }

    function setDialog(value) {
      t.is_dialog = !!value;
    }

    function setFirst(value) {
      t.is_first = !!value;
    }

    function setTitle(title) {
      t.title = title;
    }

    function storage(val) {
      if (arguments.length > 0) {
        t.storageValue = val;
      }
      return t.storageValue;
    }

    function bindHotkey(combination, callback) {
      assert(_.isString(combination) && combination, "Invalid hotkey combination");

      t.hotkeys[combination] = bHotkey(combination, callback);
    }

    function previewFile(file) {
      bPreview.open(file);
    }

    function faceCropper(file, onCrop, rounded, faceShaped) {
      bFaceCropper.open(file, onCrop, rounded, faceShaped);
    }

    function post(name, data, type, headers) {
      return bHttp.postData(t.path + justifyName(name, '$'), data, type, headers).then(function (r) {
        return r.data;
      });
    }

    function query(name) {
      assert(_.isString(name) && name, "Invalid query name");

      name = justifyName(name, ':');
      var key = name.substr(1);
      return !t.queries[key] ? t.queries[key] = bQuery(t.path + name) : t.queries[key];
    }

    function gridScroll(name, val) {
      assert(_.isString(name) && name, "Invalid grid name");

      name = t.path + ':' + name;
      return !t.gridScrolls[name] ? t.gridScrolls[name] = bGridScroll(name) : t.gridScrolls[name];
    }

    function grid(name) {
      assert(_.isString(name) && name, "Invalid grid name");

      return !t.grids[name] ? t.grids[name] = bGrid(query(name)) : t.grids[name];
    }

    function pgGrid(name) {
      assert(_.isString(name) && name, "Invalid pgGrid name");

      return !t.pgGrids[name] ? t.pgGrids[name] = bPgGrid(name) : t.pgGrids[name];
    }

    function dropzone(name) {
      // TODO review & multiselect
      assert(_.isString(name) && name, "Invalid dropzone name");

      var $dropzoneElem = t.elem.find(`b-dropzone[name="${name}"]`);

      if ($dropzoneElem.length > 0) {
        return $dropzoneElem.scope().$bDropzone;
      } else {
        console.error('Dropzone not found');
        return {};
      }
    }

    function getMap(name, $mapFrame) {
      assert(_.isString(name) && name, "Invalid map name");

      var g = t.maps[name];
      if (!g) {
        assert($mapFrame && $mapFrame.length, "Map frame is not given");
        g = bConfig.makeMapApi($mapFrame);
        t.maps[name] = g;
      }
      return g;
    }

    function broadcast(action, data) {
      if (_.isFunction(t.broadcastCallbacks[action])) {
        t.broadcastCallbacks[action](data);
      }
    }

    function on(action, callback) {
      if (_.isFunction(callback)) t.emitCallbacks[action] = callback;
    }

    function reload() {
      assert(_.isString(t.path) && t.path, "basePage path is not defined");

      t.id = _.uniqueId();
      t.formUrl = formUrl(t.path, t.param);
      t.saved = false;
      t.title = '';
      t.requires = [];
      t.onInit = null;
      t.onCtrl = null;
      t.qLoaded = $q.defer();

      t.qModel = post(':model', t.param, null, {
        formurl : t.formUrl.length > 2000 ? '' : t.formUrl
      });

      t.qContentLink = $q.defer();

      t.grids = {};
      t.pgGrids = {};
      t.maps = {};

      load().then(onDone, onFail);
    }

    function message(s, ps) {
      for (var i = 0; ps && i < ps.length; i++) {
        s = s.replace('$' + (i + 1), ps[i]);
      }
      return s;
    }

    function translate(key, ps) {
      key = (key || '').trim();
      if (!key) {
        console.error('Empty lang key');
        return key;
      }
      t.langsNew[key] = true;
      var v = t.langs[key];
      if (!v) {
        t.langs[key] = key;
        v = key;
      }
      return message(v, ps);
    }

    function translateApi(key) {
      key = translate(key);
      return function () {
        return message(key, _.toArray(arguments));
      }
    }

    translateApi.suppress = function () {
      _.each(arguments, function (k) {
        t.langsSuppress.push(k);
      });
    };

    function callInit(fn, scope, qModel) {
      if (_.isFunction(fn)) {
        try {
          $injector.invoke(fn, null, {
            scope: scope,
            qModel: qModel,
            param: angular.copy(t.param),
            xparam: angular.copy(t.xparam),
            t: translateApi
          });
        } catch (e) {
          console.error(e);
          return {
            reason: e,
            type: 'script',
            message: 'Script error: page.init <code>' + (e.message || e) + '</code> in ' + t.path
          };
        }
      }
    }

    function callCtrl(fn, scope, model) {
      var act = {
        post : post,
        S : t.open,
        D : t.openDialog,
        R : t.openReplace,
        C : t.openClear
      };
      var fi;

      if (_.isArray(model) && model.length === 4 && model[0] === '(^_^)') {
        t.setTitle(model[1].title);
        t.siblings = model[3];
        fi = makeFormInfo(act, model[1]);
        t.fi = fi;
        scope.fi = fi;
        model = model[2];

        t.setFavorite(fi.isFavorite);
      }

      if (_.isFunction(fn)) {
        try {
          $injector.invoke(fn, null, {
            scope : scope,
            model : model,
            param : angular.copy(t.param),
            xparam: angular.copy(t.xparam),
            fi : fi,
            t : translateApi
          });
        } catch (e) {
          console.error(e);
          return {
            reason : e,
            type : 'script',
            message : 'Script error: page.ctrl <code>' + (e.message || e) + '</code> in ' + t.path
          };
        }
      }
    }

    function makeScript(scr) {
      /*
        when 2nd argument passed to page.ctrl as 'autoscope'
        all public functions of context will be assigned to 'scope'
      */
      scr = scr || "";
      var ctrl = /(page\.ctrl\s*\(\s*function\s*\(.*?\)\s*{)([^]*)(}\s*\))/g;
      var rx_res = ctrl.exec(scr);
      if (rx_res) {
        var rx = /\Wfunction\s+(\w+)/g,
            eval_to_scope = '';
        while(res = rx.exec(rx_res[2])) {
          if (!res[1].startsWith("_")) {
            eval_to_scope += "  evalToScope('" + res[1] + "');\n";
          }
        }
        if (eval_to_scope.length > 0) {
          eval_to_scope = "\n  function evalToScope(fn) { try { scope[fn] = eval(fn); } catch(e) {}}\n" + eval_to_scope;
        }
        scr = scr.replace(ctrl, '$1$2' + eval_to_scope + '})');
      }
      return scr;
    }

    function onDone(data) {
      var scope = data.scope;

      scope.bPage = t;

      t.pureLangs = data.lang;
      t.custom_langs = angular.copy(data.custom_lang);
      t.langs = angular.copy(data.lang);
      t.tour = angular.copy(data.tour);

      _.each(t.custom_langs, (v, k) => {
        if (!!v) t.langs[k] = v;
      });

      t.elem = data.elem;
      t.elem.empty();
      t.elem.append(data.toolbar);
      t.elem.append(data.content);

      scope.page = t.api;

      t.api.$toolbar = t.elem.find("div.b-toolbar");
      t.api.$content = t.elem.find("div.b-content");

      var e = callScript(scope.page, data.script);
      if (e) {
        e.message += ' in ' + t.path;
        return onFail(e);
      }

      bRequire.load(...t.requires).then(x=> {
        if (t.is_init) {
          bindHotkey('alt+q', t.close);
          bindHotkey('alt+r', t.run);
        }

        e = callInit(t.onInit, scope, t.qModel);
        if (e)
          return onFail(e);

        $compile(t.elem.contents())(scope);

        t.qModel.then(function (model) {
          callCtrl(t.onCtrl, scope, model);
          if (e)
            return onFail(e);
          showElem(t.elem);
          t.qLoaded.resolve(data);
          t.is_init = false;
        }, onFail);
      });
    }

    function onFail(error) {
      t.qContentLink.promise.then(function (c) {
        c.elem.show();
        switch (error.type) {
          case "html404":
            c.elem.html('<ng-include src="\'page_not_found.html\'"/>');
            $compile(c.elem.contents())(c.scope);
            break;
          default:
            c.elem.html('<ng-include src="\'page_error.html\'"/>');
            bAlert.open(error);
        }
      });
    }

    function load() {
      var qHtml = bHttp.fetchHtml(t.path),
          qLang = $q.all([bHttp.fetchLang(t.path), bHttp.fetchCustomLang(t.path)]),
          qTour = bHttp.fetchTour(t.path);         

      function onHtmlDone(html) {
        const $q = $('<div></div>').html(html),
        script = makeScript($q.children('script[type=biruni],script[biruni]').first().text()), // TODO: remove [type="biruni"] after converting all html files to [biruni]
        toolbar = $q.children('div.b-toolbar').first(),
        content = $q.children('div.b-content').first();

        return qLang.then(function (lang) {
          var translates = {};
          for (let k in lang[0]) {
            let translate = '';

            if (typeof lang[0][k] === 'object') {
              translate = lang[0][k].translate;
              // DEPRECATED: after converting the values in the JSON files from string to object, the check for object in else is removed.
            } else {
              translate = lang[0][k]
            }
            translates[k] = translate;
          }

          return {
            script      : script,
            toolbar     : toolbar,
            content     : content,
            lang        : translates,
            custom_lang : lang[1]
          }
        });
      }

      function onLangDone(data) {
        return t.qContentLink.promise.then(function (link) {
          data.elem = link.elem;
          data.scope = link.scope;
          return data;
        });
      }

      function onTourDone(data) {
        return qTour.then(function(tour){
          data.tour = tour;
          return data;
        })
      }

      return qHtml
      .then(onHtmlDone)
      .then(onLangDone)
      .then(onTourDone);
    }
  }

  function makeFormInfo(act, fi) {
    var ls = _.mapMatrix(fi.actions || [], ['key', 'title', 'uri', 'type']),
    r = {};
    function create(key, uri, type) {
      if (uri) {
        return _.partial(act[type], uri);
      } else {
        var func = _.partial(act.post, key);

        return function(...args) {
          if (func.running) return $q(function() {return null;})
          func.running = true;
          return func(...args).finally(function() {
            func.running = false;
          });
        }
      }
    }
    for (var i = 0; i < ls.length; i++) {
      var m = ls[i];
      r[m.key] = create(m.key, m.uri, m.type);
      r[m.key].uri = m.uri;
      r[m.key].title = m.title;
    }
    r.isHead = fi.filial_head === 'Y';
    r.isFilial = fi.filial_head !== 'Y';
    r.isFavorite = fi.favorite == 'Y';
    r.form = fi.form;
    return r;
  }

  return function (path, param, xparam) {
    return new Page(path, param, xparam);
  };
});
