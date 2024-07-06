biruni.directive('bQlikpage', function ($sce, $http, bConfig, bRoutes, bAlert) {
  function notify(result) {
    let message = _.isString(result.data) ? result.data : result;
    bAlert.open(message);
  }

  function link(scope, elem, attr) {
    scope.$watch(attr.source, function(source) {
      if (!source) return;
      $http.post(bRoutes.QLIK_AUTH, _.pick(bConfig.auths(), 'project_code', 'filial_id'))
           .then(function() {
              scope.src = $sce.trustAsResourceUrl(source);
            })
           .catch(notify);
    });
  }

  return {
      restrict: 'E',
      link: link,
      template: function (elem, attr) {
        let width = attr.width ? attr.width : '100%';
        let height = attr.height ? attr.height : '1000px';

        return '<iframe ng-src="{{ src }}" style="height:' + height + ';width:' + width + ';border:none;overflow:hidden;" seamless></iframe>';
      }
  };
});