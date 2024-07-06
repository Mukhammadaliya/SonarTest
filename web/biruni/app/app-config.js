 app.config(function (uiSelectConfig) {
   uiSelectConfig.theme = 'bootstrap';
 });

app.config(function (blockUIConfig) {
  blockUIConfig.requestFilter = function (config) {
    return !config.unblock;
  };
  blockUIConfig.template = `<div class="block-ui-overlay"></div>
  <div class="block-ui-message-container" aria-live="assertive" aria-atomic="true">
    <img src="assets/img/loading.svg"/>
  </div>`;
});

app.config(function ($httpProvider) {
  $httpProvider.interceptors.push(function() {
    return {
      'request': function(config) {
        var cookie = "_lrt=" + _.now();
        var path = (document.location || {}).pathname;
        if (path) cookie += "; path=" + path;
        document.cookie = cookie;
        return config;
       }
    }
  });
});

app.config(function($locationProvider) {
  $locationProvider.hashPrefix('');
});