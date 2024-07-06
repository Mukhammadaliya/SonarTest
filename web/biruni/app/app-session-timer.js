app.factory('AppSessionTimer', function($http, $timeout, bConfig, bRoutes) {
  let timer = {
    eps: 100, // measured by milliseconds
    max_wait_time: 30000,
    max_inactive_time: 1800000,
    elem: $('#closing-session'),
    indexes: {}
  };

  _.range(timer.max_wait_time / 1000).forEach(x => timer.indexes[x] = null);
  _.range(8).forEach(x => timer.indexes[Math.floor(timer.max_wait_time / 8000 * x) + 1] = x);
  _.range(timer.max_wait_time / 1000 - 1, -1).forEach(x => timer.indexes[x] = _.isNull(timer.indexes[x]) ? timer.indexes[x + 1] : timer.indexes[x]);

  let isOpen = function() { return false; }

  function sessionOut() {
    $timeout(function() {
      bConfig.sessionOutFn()(false);
    });
  }

  function toggleDialog(show){
    if (show) {
      // Prepare "closing-session" and open timeout progress
      timer.elem.show();
      timer.elem.find('.cs-dialog.cs-timeout').show();
      $('body').addClass('blur');

      setTimeout(function () {
        timer.elem.find('.cs-backdrop,.cs-dialog.cs-timeout').addClass('open');
        timer.elem.find('.btn-primary').focus();
      }, 50);
    } else {
      // Hide timeout progress
      timer.elem.find('.cs-lock').removeClass('open').hide();
      timer.elem.find('.cs-timeout').removeClass('open');
      timer.elem.find('.cs-block-item').removeClass('closed');
    }
  }

  function prepareCS(action) {
    if (action == 'on') {
      // Clear "closing-session"
      timer.elem.find('.cs-dialog').removeClass('open').hide();
      timer.elem.find('.cs-backdrop').removeClass('open');
      timer.elem.hide();
      $('body').removeClass('blur');
    } else {
      // Prepare "closing-session"
      timer.elem.show();
      timer.elem.find('.cs-dialog.cs-timeout').hide();
      $('body').addClass('blur');
      // Open lock screen
      setTimeout(function(){
        timer.elem.find('.cs-backdrop').addClass('open');
        timer.elem.find('.cs-dialog.cs-lock').show();

        setTimeout(function(){
          timer.elem.find('.cs-dialog.cs-lock').addClass('open');
        }, 50);
      });
    }
  }

  function requestSessionInfo() {
    $http.get(bRoutes.SESSION_INFO).then(function(result) {
      result = parseInt((result.data || "").trim());
      if (result) {
        timer.max_inactive_time = (result - 10) * 1000;
        sessionAliveTimer('on');
      } else {
        sessionOut();
      }
    });
  }

  function getCookie(key) {
    try {
      return document.cookie.split(';')
                     .filter(x => x.trim().split('=')[0] === key)
                     .pop().trim().split('=').pop();
    } catch (ex) {
      return null;
    }
  }

  function getRemainSessionTime() {
    var lrt = parseInt(getCookie('_lrt'));
    if (!lrt) return null;
    return _.now() - lrt;
  }

  function controlWarnTimer(action) {
    toggleDialog(false);

    clearInterval(timer.warn);

    if (action != 'on') return;

    if (!timer.origin_title) timer.origin_title = document.title;

    toggleDialog(true);

    let max_time = timer.max_wait_time / 1000;

    function executing() {
      let rem = getRemainSessionTime();
      if (rem + timer.max_wait_time + timer.eps <= timer.max_inactive_time) {
        sessionAliveTimer('on');
      } else if (rem <= timer.max_inactive_time) {
        let wait_time = Math.floor((timer.max_inactive_time - rem) / 1000);
        if (document.hidden) {
          document.title = wait_time + " " + bConfig.langs.session_left;
        } else {
          if (timer.origin_title) document.title = timer.origin_title;
          timer.elem.find('.seconds').text(wait_time);
        }
        let index = timer.indexes[wait_time];

        if (!_.isUndefined(index)) {
          let block = timer.elem.find('.cs-block-item').get(index);
          $(block).addClass('closed');
        }
      } else {
        clearInterval(timer.warn);
        sessionOut();
      }
    }
    executing();
    timer.warn = setInterval(executing, 1000);
  }


  function sessionAliveTimer(action) {
    document.title = timer.origin_title || document.title;
    timer.origin_title = null;

    prepareCS(action);
    controlWarnTimer('off');
    clearInterval(timer.alive);

    if (action == 'on' && isOpen()) {
      var interval = 0;
      function ctrl() {
        var rem = getRemainSessionTime();
        if (rem + timer.max_wait_time + timer.eps <= timer.max_inactive_time) {
          var _interval = Math.min(timer.max_inactive_time - rem - timer.max_wait_time - timer.eps, 10000);
          if (_interval != interval) {
            interval = _interval;
            clearInterval(timer.alive);
            timer.alive = setInterval(ctrl, interval);
          }
        } else if (rem <= timer.max_inactive_time) {
          clearInterval(timer.alive);
          controlWarnTimer('on');
        } else {
          sessionOut();
        }
      }
      ctrl();
    }
  }

  return function(__isOpen) {
    isOpen = __isOpen;
    return {
      on: _.partial(sessionAliveTimer, 'on'),
      off: _.partial(sessionAliveTimer, 'off'),
      stay: requestSessionInfo
    }
  }
});
