biruni.factory('bConfirm', function ($rootScope, $timeout, bConfig) {
  var $modal = $('#biruniConfirm'),
  m = {},
  interval;

  $modal.modal({
    backdrop : true,
    keyboard : true,
    show : false
  });

  init();

  bConfig.onLocationChange(function () {
    $modal.modal('hide');
  });

  function init() {
    m.message = '';
    m.yes = _.noop;
    m.no = _.noop;
    m.cancel = _.noop;
    m.confirm = confirm;
    m.is_clicked = false;
    m.time = 0;

    m.clickYes = _=> { m.is_clicked = true; m.yes(); }
    m.clickNo = _ => { m.is_clicked = true; m.no(); }
    m.clickCancel = _=> { m.is_clicked = true; m.cancel(); }
  }

  function nvl(fn) {
    return _.isFunction(fn)? _.once(fn) : _.noop;
  }

  function setTimer(timer) {
    if (timer && parseInt(timer || 0) > 0) {
      m.time = parseInt(timer);
      interval = setInterval(function() {
        m.time--;
        // TODO: idk how yet, but sometimes the timer goes negative
        if (m.time <= 0) {
          m.time = 0;
          clearInterval(interval);
        }
        $rootScope.$digest();
      }, 1000);
    }
  }

  function confirm(message, yes, no, cancel) {
    init();
    m.message = message;
    m.yes = nvl(yes);
    m.no = nvl(no);
    m.cancel = nvl(cancel);
    m.hasCancel = _.isFunction(cancel);

    $modal.modal('show');

    return { setTimer };
  }

  $modal.on('shown.bs.modal', function() {
    $modal.find('.modal-footer').find('button').first().focus();
  });
  $modal.on("hidden.bs.modal", function(e) {
    clearInterval(interval);
    if (!m.is_clicked) {
      $timeout(function() {
        if (m.hasCancel) m.cancel();
        else m.no();
      });
    }
  });

  return m;
});
