biruni.directive('bScrollable', function() {
  return {
    restrict: 'A',
    scope: true,
    link: function(scope, elem) {
      elem.hScroll();
    }
  }
});