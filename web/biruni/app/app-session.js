app.factory('AppSession', function ($rootScope, $http, $location, $q, $timeout, AppSocket, AppSessionTimer, AppSetting, bConfig, bFrame, bForms, bRoutes, bStorage, bSessionStorage) {
  var si = {
    user: {},
    filial: {},
    project: {},
    filials: [],
    projects: [],

    rePassword: '',
    reError: '',

    notifications: {},
    messages: {}
  },
  settings = {},
  broadcast = null,
  sessionDone = $q.defer(),
  sessionOpened = false,
  timer = AppSessionTimer(isOpenSession),
  setFilialOnce = setFilial; //_.once(setFilial);

  var setFilialCallbacks = [];

  function registerSetFilialObserver(callback) {
    setFilialCallbacks.push(callback);
  }

  function notifySetFilialObservers(data) {
    angular.forEach(setFilialCallbacks, function(callback) {
      callback(data);
    });
  }

  if (('BroadcastChannel' in window) && window['BroadcastChannel'] !== null) {
    broadcast = new window.BroadcastChannel("session");

    broadcast.onmessage = function(e) {
      $timeout(function() {
        var data = e.data.split('|');
        if (data[1] !== window.location.pathname) return;
        data = data[0];
        if (data === 'open' && !sessionOpened) {
          si.rePassword = '';
          si.reError = '';
          openSession(true);
        } else
        if (data === 'lock' && sessionOpened) {
          sessionOut(true);
        } else
        if (data == 'logout' && sessionOpened) {
          // this condition processs is closed temporary.
          // logout();
        }
      });
    }
  }

  bConfig.sessionOutFn(sessionOut);
  bConfig.subscriptionEndFn(subscriptionEnd);
  bConfig.sessionConflictsFn(sessionConflicts);
  bConfig.onLocationChange(tryLocationChange);

  onInit();

  function isOpenSession() {
    return sessionOpened;
  }

  function notifySession(d) {
    if (document.hidden || !broadcast) return;
    broadcast.postMessage && broadcast.postMessage(d + "|" + window.location.pathname);
  }

  function avatarUrl(sha, big) {
    if (sha) {
      return bRoutes.LOAD_IMAGE + '&' + $.param({
        sha: sha,
        width: big ? 700 : 100,
        height: big ? 700 : 100,
        cache: true
      });
    }
    return '';
  }

  function openSession(notify) {
    sessionOpened = true;
    $http.defaults.headers.post.user_id = si.user.user_id;
    $http.defaults.headers.post.lang_code = si.lang_code;
    bConfig.langCode(si.lang_code);

    $('body>.b-session-closed').addClass('hide');
    $('body>.b-session-opened').removeClass('hide');

    // var blockUi = $('body>.block-ui-container>.block-ui-message-container');
    // blockUi.find('.block-ui-message').remove();
    // blockUi.find('.block-ui-after').css('display', 'block');

    AppSocket.open(si);
    timer.on();
    if (!notify) notifySession('open');
  }

  function evalMenus(list) {
    let menus = _.mapRows(list, ['menu_id', 'parent_id', 'name', 'order_no']);
    return _.chain(menus)
            .filter(x => !x.parent_id)
            .sortBy(x => x.order_no ? parseInt(x.order_no): -Infinity)
            .map(function(m) {
              return {
                menu_id: m.menu_id,
                name: m.name,
                menus: _.chain(menus)
                        .filter(x => x.parent_id == m.menu_id)
                        .sortBy(x => x.order_no ? parseInt(x.order_no): -Infinity)
                        .value()
              }
            }).value();
  }

  function evalForms(menus, forms, prefix) {
    menus = angular.copy(menus);
    forms = _.chain(forms)
             .mapMatrix(['menu_id', 'form', 'name', 'add_form', 'add_form_name'])
             .each(x => {
               x.url = "#" + prefix + x.form;
               x.add_form_url = "#" + prefix + (x.add_form || x.form);
             }).value();

    return _.filter(menus, m => {
              m.menus = _.filter(m.menus, c => {
                c.forms = _.filter(forms, x => x.menu_id == c.menu_id);
                return c.forms.length > 0;
              });
              return m.menus.length > 0;
            });
  }

  function setProjectConfig(project) {
    let defConfig = {
      company: {
        name: "Green White Solutions LLC",
        foundation: "2012"
      },
      about: "http://greenwhite.uz/"
    };

    let storageKey = `project_config:${project.code}`;
    let config = bStorage.json(storageKey);
    let defer = $q.defer();
    config = null;
    if (!config || config.code != project.code) {
      $http.get(`page/config/${project.code}/config.json`).then(function(result) {
        result.data.code = project.code;
        bStorage.json(storageKey, result.data);
        defer.resolve(result.data);
      });
    } else {
      defer.resolve(config);
    }

    defer.promise.then(function(config) {
      let index = (config || {}).index || {};
      project.config = deepDefaults(index, defConfig);
    });
  }

  function setSubscriptionInfo(d) {
    let info = {};
    info.has_warning = d.has_warning == 'Y';
    info.day_count = d.day_count;
    info.warning_message = d.warning_message;

    if (d.day_count > 3) info.warning = true;
    else info.danger = true;

    return info;
  }

  function loadPlugin(project) {
    if (!project.web_plugin_file) return;
    var script = document.createElement('script');
    script.src = `page/resource/${project.code}/${project.web_plugin_file}`;
    script.async = true;
    document.head.appendChild(script);
  }

  function onSessionDone(d) {
    bSessionStorage.remove('locked');
    moment.locale(d.lang_code);

    si.user = d.user;
    si.user.prefix = si.user.name.substr(0, 1).toUpperCase();
    si.avatar = avatarUrl(d.user.photo_sha);
    si.avatar_locked = avatarUrl(d.user.photo_sha, true);
    si.lang_code = d.lang_code;
    si.company_name = d.company_name;
    si.isAdmin = d.is_admin == 'Y';
    si.current_year = moment().format('YYYY');
    si.warning_message = d.warning_message;

    si.projects = _.map(d.projects, function(project) {
      let menus = evalMenus(project.menus);
      project.hash = _.padStart(project.hash, 2, "0");
      let item = {
        hash: project.hash,
        code: project.code,
        name: project.name.toLowerCase(),
        intro_form: project.intro_form,
        subscription_end_form: project.subscription_end_form,
        subscription_infos: setSubscriptionInfo(project.subscription_infos || {}),
        filials: _.chain(project.filials)
                  .mapRows(['id', 'name'])
                  .map(filial => {
                    return {
                      id: filial.id,
                      name: filial.name,
                      menus: evalForms(menus, project[filial.id], bConfig.pathPrefix(project.hash, filial.id))
                    }
                  }).value(),
        config: {}
      };

      setProjectConfig(item);
      loadPlugin(project);

      return item;
    });

    // Settings
    if ($rootScope.is_debug) {
      let prefix = location.pathname;
      AppSetting.set({
        start_kind: bStorage.json(prefix + 'start_kind').value,
        init_project: bStorage.json(prefix + 'init_project').value,
        init_filial: bStorage.json(prefix + 'init_filial').value,
        init_form: bStorage.json(prefix + 'init_form').value
      });
    } else {
      AppSetting.set(d.settings);
    }

    AppSetting.prepareInitSettings(si);

    settings = AppSetting.settings;

    // set user's default project and filial
    si.project = getInitProject();
    si.filial = getInitFilial();

    bConfig.countryCode(d.country_code);
    bConfig.setLangs(d.biruni_langs);
    bFrame.close.title = bConfig.langs.close;

    sessionDone.resolve('');
    openSession();
    tryLocationChange();

    timer.stay();

    let user_info = {
      // company
      company_code: d.company_code,
      company_name: d.company_name,
      // filial
      filial_id: si.filial.id,
      filial_name: si.filial.name,
      // user
      user_id: d.user.user_id,
      name: d.user.name,
      photo_sha: d.user.photo_sha,
      is_admin: si.isAdmin,
      // system
      lang_code: d.lang_code,
    };

    window.sessionResolver(user_info);
  }

  function getInitProject() {
    if (settings.init_project) {
      return _.findWhere(si.projects, { code: settings.init_project }) || _.first(si.projects);
    } else {
      return _.first(si.projects);
    }
  }

  function getInitFilial() {
    if (settings.init_filial) {
      return _.findWhere(si.project.filials, { id: settings.init_filial }) || _.first(si.project.filials);
    } else {
      return _.first(si.project.filials);
    }
  }

  function saveSessionUrl() {
    let val = _.pick(bFrame.parseUrl(), 'param', 'path');
    bSessionStorage.set('session_url', JSON.stringify(val));
    bSessionStorage.remove('locked');
  }

  function onSessionFail(error) {
    if (!bSessionStorage.get('locked')) saveSessionUrl();
    sessionDone.reject('');

    if (!_.isNull(error)) {
      sessionOpened = false;
      $http.post(bRoutes.CHECK_SESSION).then(() => window.location.replace('unauthenticated_session_details.html'), () => window.location.replace('login.html'));
    }
  }

  function onInit() {
    let parsed_url = bFrame.parseUrl();
    if (parsed_url.type) sessionPromise.then(onSessionDone, onSessionFail);
    else logout();
  }

  function setFilial(project_hash, filial_id) {
    let project = _.findWhere(si.projects, { hash: project_hash });

    assert(project, "project not found", x => { si = {}; sessionOpened = false; });

    let filial = !filial_id? _.first(project.filials) : _.find(project.filials, { id: filial_id });

    assert(filial, "filial or project not found", x => { si = {}; sessionOpened = false; });

    si.project = project;
    si.filial = filial;

    bConfig.auths({
      project_code: project.code,
      project_hash: project.hash,
      filial_id: filial.id,
      user_id: si.user.user_id,
      lang_code: si.lang_code
    });

    $http.defaults.headers.post.project_code = project.code;
    $http.defaults.headers.post.filial_id = filial.id;

    $http.defaults.headers.common.project_code = project.code;
    $http.defaults.headers.common.filial_id = filial.id;

    notifySetFilialObservers({project_code: project.code, filial_id: filial.id});
  }

  function lockScreen() {
    $http.post(bRoutes.LOGOUT);
    bSessionStorage.set('locked', true);
    sessionOut();
  }

  function sessionOut(notify) {
    if (!sessionOpened) {
      logout();
      return;
    }
    sessionOpened = false;
    if (!notify) notifySession('lock');
    timer.off();
    AppSocket.close();

    if (si.user && si.user.login) {
      si.rePassword = '';
      si.reError = '';
    } else logout();
  }

  function sessionStay() {
    timer.stay();
  }

  function subscriptionEnd() {
    bFrame.openReplace(si.project.subscription_end_form);
  }

  function sessionConflicts() {
    bFrame.openReplace(bForms.SESSION_CONFLICTS);
  }

  function logout() {
    sessionOpened = false;
    AppSocket.close();
    $http.post(bRoutes.LOGOUT);
    window.location.replace('login.html');
  }

  function logoutAndForget() {
    sessionOpened = false;
    AppSocket.close();
    $http.post(bRoutes.LOGOUT_AND_FORGET);
    window.location.replace('login.html');
  }

  function introPage(pr_code) {
    let project_code = pr_code || si.project.code;
    let val = _.findWhere(si.projects, {code: project_code});
    if (val && val.intro_form) return val.intro_form;
    return bForms.DASHBOARD;
  }

  function getSessionUrl() {
    let session_url = window.sessionStorage.getItem('session_url');
    bSessionStorage.remove('session_url');

    if (session_url) {
      let parsed_url = JSON.parse(session_url);
      let project = _.findWhere(si.projects, { hash: parsed_url.param["-project_hash"] });

      if (project) {
        let param = _.omit(parsed_url.param, '-project_hash');
        param["-project_code"] = project.code;
        return {
          url: parsed_url.path,
          search: param
        };
      } else return '';
    } else return '';
  }

  function redirectToInit() {
    let url = bConfig.pathPrefix(si.project.hash, si.filial.id);
    let session_url = getSessionUrl();

    if (session_url) {
      url = session_url.url;
      $location.search(session_url.search);
    } else if (settings.start_kind == 'C' && settings.init_form) {
      url += settings.init_form;
    } else {
      url += introPage(si.project.project_code);
    }

    $location.path(url);
    $location.replace();
  }

  function normalizeLocation(parsed_url) {
    let project = _.findWhere(si.projects, {code: parsed_url.param["-project_code"]});
    if (project) {
      let url = bConfig.pathPrefix(project.hash, parsed_url.param["-filial_id"]) +
                parsed_url.url;
      $location.path(url);
      $location.search(parsed_url.pure_param);
      $location.replace();
    } else logout();
  }

  function redirectPasswordChange(project_hash, filial_id) {
    let url = bConfig.pathPrefix(project_hash, filial_id) +
              bForms.CHANGE_PASSWORD;
    $location.path(url);
    $location.replace();
  }

  function forceLocationChange() {
    let parsed_url = bFrame.parseUrl();
    let param = parsed_url.param;
    switch (parsed_url.type) {
      case "ready":
        if (si.user.password_change_required == 'Y' && parsed_url.path !== bForms.CHANGE_PASSWORD)
          redirectPasswordChange(param["-project_hash"], param["-filial_id"]);
        else {
          setFilialOnce(param["-project_hash"], param["-filial_id"]);
          bFrame.onLocationChange(parsed_url);
        }
        break;
      case "redirect": redirectToInit(); break;
      case "normalize": normalizeLocation(parsed_url); break;
      default: logout();
    }
  }

  function tryLocationChange() {
    if (!sessionOpened) return;
    try {
      $('html').animate({ scrollTop: 0 }, 200);
      forceLocationChange();
    } catch (e) {
      console.error(e);
      sessionOut();
    }
  }

  return {
    si: si,
    sessionDone: sessionDone.promise,
    introPage: introPage,
    registerSetFilialObserver: registerSetFilialObserver,
    setFilial: setFilial,
    openSession: openSession,
    logout: logout,
    logoutAndForget: logoutAndForget,
    lockScreen: lockScreen,
    sessionStay: sessionStay
  }
});
