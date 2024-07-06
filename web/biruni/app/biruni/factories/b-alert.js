biruni.factory('bAlert', function (bConfig) {
  var $modal = $('#biruniAlert'),
      $modalExtended = $('#biruniAlertExtended'),
      modal = $modal,
  m = {
    open : open,
    openReal : open,
    hide : hide
  };

  $modal.modal({
    backdrop : true,
    keyboard : true,
    show : false
  });

  $modalExtended.modal({
    backdrop : true,
    keyboard : true,
    show : false
  });

  $modalExtended.on('hidden.bs.modal', function () {
    $('.collapse').collapse('hide');
  });

  bConfig.onLocationChange(hide);

  init();

  function init() {
    modal = $modal;
    m.title = '';
    m.message = '';
    m.uri = '';
    m.route = false;
    m.solutions = [];
    m.code = '';
  }

  function open(error, title) {
    if (error && (error.type == 'route401' || error.type == 'route402' || error.type == 'route409')) {
      return;
    }
    if (!_.isString(title)) {
      title = '';
    }
    init();
    if (_.isString(error)) {
      m.title = title || bConfig.langs.error;
      m.message = error;
    } else {
      m.title = bConfig.langs.error;
      if (error.type == 'ex') {
        m.message = bConfig.langs.upload_file_changed;
      } else {
        if (_.isString(error.data) || _.isEmpty(error.data) || !_.has(error.data, 'error_code')) {
          m.message = error.message;
        } else {
          modal = $modalExtended;

          m.message = error.data.message;
          m.title = error.data.title || m.title;
          m.code = error.data.error_code;

          if (!_.isEmpty(error.data.solutions)) {
            m.solutions = error.data.solutions;
          }
        }
        
        m.uri = error.path;
        m.route = 'route404' === error.type;
        if (error.type === 'route403') {
          m.title = bConfig.langs.unauthorized;
        }
      }
    }
    modal.modal('show');
  }

  function hide() {
    modal.modal('hide');
  }

  return m;
});
