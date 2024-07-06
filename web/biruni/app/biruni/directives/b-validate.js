biruni.directive('bValidate', function () {
  function link(scope, elem, attr, ctrl) {
    scope.$watch(attr.bValidate, function(options) {
      if (options) {
        if (typeof options === "object") {
          _.each(options, (v, k) => ctrl.$setValidity(k, v));
        } else {
          ctrl.$setValidity('bValidate', options);
        }
      }
    });
  }

  return {
    restrict: 'A',
    require: 'ngModel',
    link: link
  }
});