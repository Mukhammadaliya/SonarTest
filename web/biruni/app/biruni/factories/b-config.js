biruni.factory('bConfig', function ($rootScope, $q, bLangs) {
  const u = {
    auth: {},
    langs: {},
    langCode: 'en',
    countryCode: 'uz',
    sessionOutFn: sessionOut,
    subscriptionEndFn: subscriptionEnd,
    sessionConflictsFn: sessionConflicts
  };

  _.each(bLangs, (val, key) => u.langs[key.toLowerCase()] = val);

  function setLangs(langs) {
    _.each(langs, (val, key) => {
      if (_.has(u.langs, key) && val) u.langs[key] = val;
    });
  }

  function sessionOut() {
    window.alert('Session out');
  }

  function subscriptionEnd() {
    window.alert('Subscription End!');
  }

  function sessionConflicts() {
    window.alert('SessionConflicts!');
  }

  function langCode(lc) {
    return arguments.length? u.langCode = lc || "en" : u.langCode;
  }

  function pathPrefix(project_hash, filial_id) {
    if (!project_hash) {
      project_hash = u.auth.project_hash;
      filial_id = u.auth.filial_id;
    }
    assert(project_hash && filial_id, "gen path prefix error");
    // prefix starts with "1"
    // following 4 number uniq page hashcode
    // next 2 number identify project hashcode
    // remain numbers identify filial id

    return "/!" + parseInt("1" + _.padStart(Math.floor(_.now() % 10000000 / 1000).toString(), 4, "0") +
                                 _.padStart(project_hash, 2, "0") + filial_id).toString(36);
  }

  function auths(v) {
    return arguments.length ? u.auth = v : u.auth;
  }

  function countryCode(code) {
    return arguments.length? u.countryCode = code || 'uz' : u.countryCode;
  }

  function sessionOutFn(sof) {
    return arguments.length ? u.sessionOutFn = sof : u.sessionOutFn;
  }

  function subscriptionEndFn(sef) {
    return arguments.length ? u.subscriptionEndFn = sef : u.subscriptionEndFn;
  }

  function sessionConflictsFn(scf) {
    return arguments.length ? u.sessionConflictsFn = scf : u.sessionConflictsFn;
  }

  function onLocationChange(fn) {
    $rootScope.$on('$locationChangeSuccess', fn);
  }

  const entityMap = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#39;',
    '/': '&#x2F;',
    '`': '&#x60;',
    '=': '&#x3D;'
  };

  function escapeHtml(string) {
    return String(string).replace(/[&<>"'`=\/]/g, function fromEntityMap(s) {
      return entityMap[s];
    });
  }

  function escapeLikeValue(val) {
    return val.replace(/[%_\\]/g, x => '\\' + x);
  }

  function unescapeLikeValue(val) {
    return val.replace(/(\\%)|(\\_)|(\\\\)/g, x=> x[1]);
  }

  function makeMapApi($mapFrame) {
    const mf = $mapFrame[0],
        qApi = $q.defer();

    function biruniLangs() {
      return r.langs;
    }

    function init(d) {
      d = d || {};
      mf.src = 'map_module/map.html';
      mf.onload = function () {
        let langs = biruniLangs;
        langs.langCode = r.langCode();
        qApi.resolve(mf.contentWindow.init(langs, {
          mode: d.mode, // default - show,
          selectionHandler: d.selectionHandler, // in select mode we can provide callback for selection
          toolbar: d.toolbar, // optional, provides geoman toolbar options when mode == "select"
          center: [d.lat || 41.2, d.lng || 69.2], // default Tashkent
          zoom: d.zoom || 15,
          fullscreen: d.fullscreen,     // is fullscreen button enabled
          showProfiles: d.showProfiles, // show/hide profile buttons (truck, car, biking, walking)
          profile: d.profile,           // default profile for routing
          mapCallbacks: d.mapCallbacks,  // callback functions to use them inside map
          allowedProfiles: d.allowedProfiles // allowed profiles for routing
        }));
      };
    }

    qApi.promise.init = init;

    return qApi.promise;
  }

  const r = {
    auths : auths,
    langCode : langCode,
    pathPrefix : pathPrefix,
    sessionOutFn : sessionOutFn,
    subscriptionEndFn : subscriptionEndFn,
    sessionConflictsFn : sessionConflictsFn,
    langs : u.langs,
    setLangs: setLangs,
    onLocationChange : onLocationChange,
    escapeHtml : escapeHtml,
    escapeLikeValue: escapeLikeValue,
    unescapeLikeValue: unescapeLikeValue,
    makeMapApi : makeMapApi,
    countryCode : countryCode,
  };

  return r;
});
