app.factory('AppSocket', function($http, $rootScope, bRoutes, bConfig, bConstants) {
  let si = {}, ws = null;

  function formatTime(time) {
    moment.locale(bConfig.langCode());
    const date = moment(time, 'DD.MM.YYYY HH:mm:ss'),
        today = moment();
    if (date.year() === today.year()
        && date.month() === today.month()
        && date.date() === today.date()) {
          return date.format('LT');
    }
    return date.format('MMM D').charAt(0).toUpperCase() + date.format('MMM D').slice(1);
  }

  function loadNotifications() {
    si.notifications = [];
    $http.post(bRoutes.NOTIFICATIONS, null, {
      unblock : true
    }).then(function (d) {
      const mapType = {
            'P': 'label-primary',
            'S': 'label-success',
            'I': 'label-info',
            'W': 'label-warning',
            'D': 'label-danger'
          },
          mapIcon = {
            'P': 'fa-plus',
            'S': 'fa-thumbs-o-up',
            'I': 'fa-info',
            'W': 'fa-warning',
            'D': 'fa-bell'
          };
      si.notifications = _.map(d.data, function (item) {
        item.className = mapType[item.type];
        item.classIcon = mapIcon[item.type];
        item.time = formatTime(item.time);
        return item;
      });
    });
  }

  function loadAlerts() {
    si.alerts = [];
    $http.post(bRoutes.ALERTS, null, {
      unblock : true
    }).then(function (d) {
      _.each(d.data, function (message) {
        $.notify({
          message : message
        }, {
          placement : {
            from : 'bottom'
          }
        });
      });
    });
  }

  function open(__si) {
    si = __si;

    loadNotifications();
    loadAlerts();

    function getUrl() {
      const l = window.location;
      return ((l.protocol === 'https:') ? 'wss://' : 'ws://') + l.host + l.pathname;
    }
    ws = new WebSocket(getUrl() + 'broadcast');

    ws.onopen = function (ev) {}
    ws.onmessage = function (ev) {
      const d = JSON.parse(ev.data);
      switch (d.type) {
        case 'alert':
          if (d.message) {
            $.notify({
              message : d.message
            }, {
              type: d.message_type || 'info',
              placement : {
                from : d.message_placement || 'bottom',
              }
            });
          }
          break;
        case 'notification': loadNotifications(); break;
        case 'load_alert': loadAlerts(); break;
      }
      $rootScope.$broadcast(bConstants.BROADCAST_ALERT_EVENT, d.data || {});
      if (d.mute !== 1) {
        document.getElementById('biruniBeep').play();
      }
    };
    ws.onclose = function (ev) {};
  }

  function close() {
    if (ws != null && ws.constructor === WebSocket) ws.close();
  }

  return {
    open: open,
    close: close
  }
});
