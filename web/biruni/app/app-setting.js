app.factory('AppSetting', function($rootScope, $http, bFonts, bRoutes, bHttp, bStorage) {
  const settings = {
    start_kind: 'D',
    init_project: '',
    init_filial: '',
    init_form: ''
  };

  function save(key) {
    if ($rootScope.is_debug) {
      bStorage.json(location.pathname + key, { value: settings[key] });
    } else {
      bHttp.unblockOnce();
      $http.post(bRoutes.SAVE_USER_SETTING, {
        head: 'Y',
        setting_code: key, 
        setting_value: settings[key]
      });
    }
  }

  function prepareMenuForms() {
    settings.forms = [];

    let filial = _.findWhere(settings.filials, {id: settings.init_filial});

    if (!filial) filial = _.first(settings.filials);

    _.each(filial.menus, function(m) {
      if (!m.menu_id) return;
      push(m, '');
      _.each(m.menus, function(x) {
        push(x, m.menu_id);
        _.each(x.forms, function(f) {
          push(f, x.menu_id, _.uniqueId(100));
        });
      });
    });

    function push(item, parent_id, menu_id) {
      settings.forms.push({
        menu_id: menu_id || item.menu_id,
        disabled: !item.form,
        form: item.form,
        name: item.name,
        parent_id: parent_id
      });
    }

    if (settings.init_form) {
      const form = _.findWhere(settings.forms, {form: settings.init_form});
      settings.init_form_id = form ? form.menu_id : '';
    }

    if (!settings.init_form_id) {
      _.any(settings.forms, function(f) {
        if (f.form) {
          settings.init_form_id = f.menu_id;
          return true;
        }
      });
    }
  }

  function prepareInitSettings(si) {
    let project = _.findWhere(si.projects, { code: settings.init_project }) || _.first(si.projects);
    settings.projects = si.projects;
    settings.init_project = project.code;

    settings.filials = project.filials;
    settings.init_filial = _.findIndex(settings.filials, { id: settings.init_filial }) > -1 ? settings.init_filial : _.first(settings.filials).id;

    prepareMenuForms();

    settings.changeStartKind = function() {
      save('start_kind');
      saveInitSettings();
    }

    settings.changeProject = function() {
      const project = _.findWhere(si.projects, {code: settings.init_project});
      settings.filials = project.filials;
      prepareMenuForms();
      saveInitSettings();
    }

    settings.changeFilial = function() {
      prepareMenuForms();
      saveInitSettings();
    }

    settings.selectForm = function(row) {
      settings.init_form = row.form;
      saveInitSettings();
    }

    function saveInitSettings() {
      save('init_project');
      save('init_filial');
      save('init_form');
    }
  }

  return {
    settings: settings,
    save: save,
    prepareInitSettings: prepareInitSettings,
    set: function(new_settings) {
      _.each(new_settings, function(val, key) {
        if (val) {
          settings[key] = val;
        }
      });
    }
  };
});
