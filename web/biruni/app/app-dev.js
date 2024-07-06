angular.module('app').controller('AppDev', function ($rootScope, $scope, bConfig, bFrame, bAlert, bHttp, $http, $q, $location, AppSession, $filter) {
  $rootScope.is_debug = true;

  const a = $scope.a;

  a.reloginData = function () {
    return {
      login : a.session.si.user.login
    };
  };

  a.globalHotkey("ctrl+o", openPage);

  $scope.$parent.b_$DEV = {
    openPage: openPage,
    isForm: isForm,
    editForm: editForm,
    editLang: editLang,
    editLangMultiple: editLangMultiple,
    toggleTranslate: toggleTranslate,
    clickSubpage: clickSubpage,
    openSubpage: openSubpage,
    editTour: editTour,
    subpages: []
  };

  bHttp.loadUri = loadUri;

  bConfig.onLocationChange(function() {
    a.translating = false;
    $('b-page').removeClass('translating');
  });

  window.BS = a;
  prepareProject();
  prepareMenu();

  function prepareProject() {
    $http.post('b/core/md/dev/get_projects').then(function (result) {
      const availCodes = _.chain(result.data)
          .each(function (item) {
            item[1] = String(item[1]).trim().split(',');
          })
          .object()
          .value();

      window.bProject = {
        data: result.data, // Otabek: I don't know why this is needed
        codes: availCodes,
        codeOfUri: function (uri) {
          const codes = this.codes;
          const str = String(uri).substring(1);
          const prefix = str.substring(0, str.indexOf('/'));
          let projectCode = '';
          _.each(codes, function (val, key) {
            if (_.contains(val, prefix)) {
              if (projectCode) throw 'Duplicate project code';
              projectCode = key;
            }
          });
          if (!projectCode) throw 'Project code not found';
          return projectCode;
        }
      };
    });
  }

  function prepareMenu() {
    $http.post('b/core/md/dev/get_menus').then(function(menu) {
      AppSession.sessionDone.then(function() {
        _.each(AppSession.si.projects, function(project) {
          _.each(project.filials, function(filial){
            const menu_forms = angular.copy(menu.data);
            _.each(menu_forms, function (m) {
              _.each(m.forms, function (f) {
                f.url = '#' + bConfig.pathPrefix(project.hash, filial.id) + f.uri;
              });
            });
            filial.menus.push({
              name : 'Developer',
              menus : menu_forms
            });
          });
        });
      });
    });
  }

  bAlert.open = function (error, title) {
    if(error && error.type === 'route404') {
      $http.get('b/core/md/dev/get_procedures?path=' + bHttp.extractPath(error.path || ''))
           .then(function (result) {
            bAlert.procedures = _.map(result.data.procedures, x => x = {name: x});
           }, function (error) {
            bAlert.procedures = [];
            console.error(error);
           });
    }
    bAlert.openReal(error, title);
  };

  bAlert.addRoute = function addRoute(row) {
    const data = {
      uri: bAlert.uri,
      action_name: row.name
    };
    $http.post('b/core/md/dev/save_route', data)
    .then(function () {
      bAlert.hide();

      const path = bHttp.extractPath(bAlert.uri);
      const project_code = bProject.codeOfUri(path);
      $http.post('b/core/md/dev/form:gen_form', {path:path})
      .then(function(result) {
        if (isForm()) {
          $http.post('dev/' + project_code + '/save/oracle/uis/form' + path + '.sql', result.data)
               .then(()=> window.location.reload(), x=> console.error(x));
        } else {
          window.location.reload();
        }
      });
    }, function (error, status) {
      window.alert('Status:' + status + '\nError:' + JSON.stringify(error));
    });
  };

  bHttp.fetchLang = _.wrap(bHttp.fetchLang, function (func, path) {
    if (bConfig.langCode() !== 'dev' && !path.startsWith('/core/md/dev')) {
      return func(path);
    }
    return $q.when({});
  });

  function openPage() {
    const path = bHttp.extractPath(bFrame.parseUrl().path);
    return $http.get('dev/' + bProject.codeOfUri(path) + '/open/page/form' + path + '.html');
  }

  function isForm() {
    const p = $location.path();
    return !(/\/core\/md\/dev\//.test(p));
  }

  function editForm() {
    bFrame.open('/core/md/dev/form', {
      form : bFrame.parseUrl().path
    });
  }

  function editLang(path = bFrame.parseUrl().path) {
    bFrame.open('/core/md/dev/form_translate', {
      form : path
    });
  }

  function editLangMultiple() {
    bFrame.open('/core/md/dev/form_translate_multiple', {
      form : bFrame.parseUrl().path
    });
  }

  function loadUri(uri) {
    const options = {
      transformResponse: null
    };
    return $http.get(uri, options).then(function (response) {
      if (response.headers('BiruniStaticPage') === 'Yes') {
        return '<biruni-static-page/>' + response.data;
      }
      return response.data;
    }, function (response) {
      return $q.reject(response);
    });
  }

  function toggleTranslate() {
    a.translating = !a.translating;

    if (!a.translating) {
      saveTranslate();
    }
    const page = _.last(bFrame.pages);
    page.elem.toggleClass('translating');
  }

  function saveTranslate() {
    const page = _.last(bFrame.pages);
    const path = 'page/lang/' + bConfig.langCode() + bHttp.extractPath(page.path) + '.json';
    $http.post('dev/' + bProject.codeOfUri(page.path) + '/save/' + path, $filter('json')(_.pick(page.pureLangs, _.identity), 1))
  }

  function clickSubpage() {
    const page = _.last(bFrame.pages);
    // first time setup path from form-info
    _.each(Object.keys(page.subpages), sbn => {
      let subPage = page.subpages[sbn];
      if (!subPage.path && page.fi[sbn]?.uri) {
          subPage.path = page.fi[sbn].uri;
      }
      subPage.title = page.fi[sbn]?.title ?? subPage.path;
    });
    a.subpages = _.filter(page.subpages, x => x.path);
  }

  function openSubpage(page) {
    if(!page.formUrl){
      bAlert.open('To open a subpage, you must first open the subpage at least once on the main page.', 'error');
    } else {
      window.open('#' + bConfig.pathPrefix() + page.formUrl);
    }
  }

  function editTour(path = bFrame.parseUrl().path) {
    bFrame.open('/core/md/dev/form_tour', {
      form : path
    });
  }
});
