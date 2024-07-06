app.controller('AppCtrl', function ($scope, $http, $timeout, bConfig, bFrame, bAlert, bConfirm, bGridFilter, bPgGridFilter, bSortForm, bHttp, bForms, bRoutes, bHotkey, bPreview, bFaceCropper, AppSession, AppSearch, AppHotkey, AppSetting, AppFeedback, $sanitize) {
  const a = {
    bConfig: bConfig,
    bFrame: bFrame,
    bAlert: bAlert,
    bConfirm: bConfirm,
    bGridFilter: bGridFilter,
    bPgGridFilter: bPgGridFilter,
    bSortForm: bSortForm,
    bPreview: bPreview,
    bFaceCropper: bFaceCropper,
    session: AppSession,
    search: AppSearch,
    settings: AppSetting.settings,
    feedback: AppFeedback,
    openProfile: openForm(bForms.PROFILE),
    openChangePassword: openForm(bForms.CHANGE_PASSWORD),
    openFileManager: openForm(bForms.FILE_MANAGER),
    openNotificationList: openForm(bForms.NOTIFICATION_LIST),
    openNotification: openForm(bForms.NOTIFICATION),
    openMessageList: openForm(bForms.MESSAGE_LIST),
    openMessage: openForm(bForms.MESSAGE_LIST),
    openTaskList: openForm(bForms.TASK_LIST),
    openSibling: openSibling,
    openAddTask: openAddTask,
    changeFilial: changeFilial,
    setProject: setProject,
    prepareProjects: prepareProjects,
    relogin: relogin,
    reloginData: reloginData,
    logout: logout,
    logoutAndForget: logoutAndForget,
    selectFont: selectFont,
    applyTheme: applyTheme,
    applyBackground: applyBackground,
    changeGridType: changeGridType,
    goBack: goBack,
    toggleFavorite: toggleFavorite,
    sendAccessRequest: sendAccessRequest,
    showAccessRequest: showAccessRequest,
    showSetAccess: showSetAccess,
    showCustomTranslate: showCustomTranslate,
    setAccess: setAccess,
    customTranslate: customTranslate,
    openDashboard: openDashboard,
    showPageBar: showPageBar,
    toggleFullScreen: toggleFullScreen,
    openSidebar: openSidebar,
    closeSidebar: closeSidebar,
    globalHotkey: globalHotkey,
    setMenuPosition: setMenuPosition,
    hasTour: hasTour, 
    showTour: showTour,
    isFavorite: false,
    temp_project: null,
    quick_sidebar: {},
    hotkeys: {},
    searchFilial: {name: ''}
  };

  $scope.a = a;

  bFrame.setFavorite = function (value) {
    $scope.a.isFavorite = value;
  }

  applyHotkeys();

  function openDashboard() {
    bFrame.openClear(AppSession.introPage());
  }

  var sidebarCanOpen = true;

  function sidebarKeydown(event) {
    if (event.keyCode == 27) closeSidebar();
  }

  function openSidebar(tab) {
    if (!sidebarCanOpen) return;
    var sidebarOverlay = $('<div>').addClass('quick-sidebar-overlay modal-backdrop show').on('click', closeSidebar);
    var sidebar = $('#kt_quick_sidebar').addClass('tab-open').after(sidebarOverlay).focus();
    sidebar.on('keydown', sidebarKeydown);
    sidebarCanOpen = false;
    a.quick_sidebar[tab] = true;
    AppHotkey.pause(true);
  }

  function closeSidebar() {
    var sidebar = $('#kt_quick_sidebar').removeClass('tab-open');
    $timeout(function () {
      sidebarCanOpen = true;
    }, 300);
    $('.quick-sidebar-overlay').remove();
    a.quick_sidebar = {};
    sidebar.off('keydown', sidebarKeydown);
    AppHotkey.pause(false);
  }

  function setMenuPosition(event) {
    var $toggle = $(event.target).closest('.menu-toggle')
    var $menu = $toggle.next('.menu-submenu');
    if ($menu.length > 0) {
      var min = $(window).width() - $menu.width() - 10;
      $menu.css('left', Math.min($toggle.offset().left, min));
    }
  }

  function toggleFullScreen() {
    if (document.fullscreenElement || document.webkitFullscreenElement || document.mozFullScreenElement) {
      if (document.cancelFullScreen) {
        document.cancelFullScreen();
      } else if (document.mozCancelFullScreen) {
        document.mozCancelFullScreen();
      } else if (document.webkitCancelFullScreen) {
        document.webkitCancelFullScreen();
      }
    } else {
      var elem = document.documentElement;
      if (elem.requestFullScreen) {
        elem.requestFullScreen();
      } else if (elem.mozRequestFullScreen) {
        elem.mozRequestFullScreen();
      } else if (elem.webkitRequestFullScreen) {
        elem.webkitRequestFullScreen();
      }
    }
  }

  function openAddTask(getForm) {
    if (getForm) {
      var url = bFrame.parseUrl();
      bFrame.open(bForms.TASK_ADD, null, _, {
        form: url.path,
        form_param: url.pure_param
      });
    } else {
      openForm(bForms.TASK_ADD)();
    }
  }

  function openForm(uri) {
    return function (param) {
      bFrame.openClear(uri, param);
    }
  }

  function reloginData() {
    return {
      login: AppSession.si.user.login,
      password: AppSession.si.rePassword
    };
  }

  async function shaSHA1(text) {
    const hash = await CryptoJS.SHA1(text);
    return hash.toString();
  }

  function requestLogin(data) {
    $http.post(bRoutes.LOGIN, data).then(function done(d) {
      let res = d.data;
      if (res.status === 'logged_in') {
        AppSession.openSession();
        const p = _.last(bFrame.pages);
        if (p && p.qLoaded.promise.$$state.status === 0) {
          bFrame.close();
        }
      } else {
        window.sessionStorage.setItem("token", res.token);
        window.sessionStorage.setItem("expires_in", res.expires_in);
        window.location.replace(res.context_path + '/login_with_otp.html?sent=true');
      }
    }, function fail(e) {
      AppSession.si.reError = bConfig.langs.password_is_incorrect;
    });
  }

  function relogin() {
    let reloginData = a.reloginData();
    if (reloginData.password) {
      shaSHA1(reloginData.password).then(function (hash) {
        reloginData.password = hash;
        requestLogin(reloginData);
      });
    } else {
      requestLogin(reloginData);
    }
  }

  function logout(force) {
    if (force) {
      AppSession.logout();
    } else {
      bConfirm.confirm(bConfig.langs.confirm_logout, AppSession.logout);
    }
  }

  function logoutAndForget(force) {
    if (force) {
      AppSession.logoutAndForget();
    } else {
      bConfirm.confirm(bConfig.langs.confirm_logout_and_forget, AppSession.logoutAndForget);
    }
  }

  function setProject(project, f) {
    a.temp_project = project;
  }

  var enableProjectHover = _.once(function () {
    $('.menus>.project-list').click(function (ev) {
      ev.stopPropagation();
    }).find('a').click(function () {
      var $this = $(this);
      var project = AppSession.si.projects[$this.index() - 1];

      // Simulate filial list update
      if (a.temp_project.hash != project.hash) {
        $('.menus>.filial-list').css('opacity', 0);
        setTimeout(function () {
          $('.menus>.filial-list').css('opacity', 1);
        }, 100);
      }

      $scope.$apply(function () {
        setProject(project);
      });

      $this.parent().children().removeClass('selected');
      $this.addClass('selected');
    });
  });

  function prepareProjects(event) {
    enableProjectHover();
    _.each(AppSession.si.projects, function (project) {
      if (project.hash == AppSession.si.project.hash) {
        setProject(project);
      }
    });
    if (AppSession.si.project.filials.length >= 10) {
      $timeout(function() {
        $(event.target).closest('.hover').find('input[name="filialSearch"]').focus();
      });
    }
  }

  function changeFilial(filial_id) {
    if (AppSession.si.project.hash != a.temp_project.hash || AppSession.si.filial.id != filial_id) {
      AppSession.setFilial(a.temp_project.hash, filial_id);
      bFrame.openClear(AppSession.introPage());
    }
  }

  function goBack(n) {
    window.history.go(- (n + 1));
  }

  function toggleFavorite() {
    var page = _.last(bFrame.pages),
      data = {};
    if (page) {
      data.url = page.formUrl;
      data.state = a.isFavorite ? 'N' : 'Y';
      bHttp.postData(bRoutes.FAVORITE, data).then(function () {
        a.isFavorite = !a.isFavorite;
      }, bAlert.open);
    }
  }

  function sendAccessRequest() {
    var page = _.last(bFrame.pages);
    if (page && showAccessRequest()) {
      bFrame.openDialog(bForms.ACCESS_REQUEST, { form: page.path });
    }
  }

  function showAccessRequest() {
    var page = _.last(bFrame.pages);
    return page && !AppSession.si.isAdmin && page.path != bForms.ACCESS_REQUEST;
  }

  function setAccess() {
    var page = _.last(bFrame.pages);
    if (page && showSetAccess()) {
      bFrame.openDialog(bForms.SET_ACCESS, { form: page.path });
    }
  }

  function showSetAccess() {
    var page = _.last(bFrame.pages);
    return page && AppSession.si.isAdmin && page.path != bForms.SET_ACCESS;
  }

  function customTranslate() {
    var page = _.last(bFrame.pages);
    if (page && showCustomTranslate()) {
      bFrame.open(bForms.CUSTOM_TRANSLATE, { form: page.path });
    }
  }

  function showCustomTranslate() {
    var page = _.last(bFrame.pages);
    return page && AppSession.si.isAdmin && page.path != bForms.CUSTOM_TRANSLATE;
  }

  function openSibling(url) {
    bFrame.open(url);
  }

  function showPageBar() {
    var bPage = _.last(a.bFrame.pages) || {};
    return bPage.show_bar;
  }

  function selectFont() {
    AppSetting.applyFont();
    AppSetting.save('user_font');
  }

  function applyTheme() {
    AppSetting.applySetting('theme');
    AppSetting.save('user_theme');
  }

  function applyBackground() {
    AppSetting.applySetting('background');
    AppSetting.save('user_background');
  }

  function changeGridType() {
    AppSetting.applySetting('grid_type');
    AppSetting.save('user_grid_type');
  }

  function globalHotkey(combination, callback) {
    assert(_.isString(combination) && combination, "Invalid global hotkey combination");

    return !a.hotkeys[combination] ? a.hotkeys[combination] = bHotkey(combination, callback, true) : a.hotkeys[combination];
  }

  function applyHotkeys() {
    globalHotkey("F2", a.search.openSearch);
    globalHotkey("alt+l", AppSession.lockScreen);

    AppHotkey.addKeySetGetter(function () {
      return a.hotkeys;
    });

    AppHotkey.addKeySetGetter(function () {
      return bFrame.pages.length > 0 ? _.last(bFrame.pages).hotkeys : {};
    });

    AppHotkey.on();
  }

  function sanitizeData(items) {
    return items.map(x => {
      return {
        element: $sanitize(x.element),
        popover: {
          title: $sanitize(x.popover.title),
          description: $sanitize(x.popover.description),
          side: $sanitize(x.popover.side),
          align: $sanitize(x.popover.align)
        }
      };
    });
  }

  function hasTour() {
    var page = _.last(bFrame.pages);
    return !_.isEmpty(page.tour); 
  }

  function showTour() {
    var page = _.last(bFrame.pages);

    if (!_.isEmpty(page.tour)){
      const driver = window.driver.js.driver;

      const driverObj = driver({
        nextBtnText: bConfig.langs.next,
        prevBtnText: bConfig.langs.previous,
        doneBtnText: bConfig.langs.done,
        showProgress: true,
  
        onPopoverRender: (popover, { config, state }) => {
          // add class for make it look like a bootstraop buttons
          let nextButton = popover.nextButton;
          nextButton.classList.add('btn', 'btn-primary');
          nextButton.style.textShadow = 'none';

          let previousButton = popover.previousButton;
          previousButton.classList.add('btn', 'btn-secondary');
          previousButton.style.textShadow = 'none';
        },
  
        steps: sanitizeData(page.tour).filter(step => step.element)
      });
      
      driverObj.drive();
    }
  }
});
