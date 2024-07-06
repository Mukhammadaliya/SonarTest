// Modifying 3rd party UI-SELECT directive to control the opening of a dropdown menu
biruni.directive('uiSelect', function($timeout) {
  return {
    link: function($scope, elem) {
      let hintElement;

      function controlHint() {
        var elemRect = elem[0].getBoundingClientRect();
        var scrollParent = elem.scrollParent();

        scrollParent.scroll(function(ev) {
          hintElement.position({
            of: elem,
            my: 'left top',
            at: 'left bottom',
            collision: 'fit flipfit',
            within: $(this)
          });
        });
        hintElement.css({
          opacity: 1,
          width: elemRect.width
        });
        hintElement.position({
          of: elem,
          my: 'left top',
          at: 'left bottom',
          collision: 'fit flipfit'
        });
      }

      $scope.$watch('$select.open', function(v) {
        if (v === true) {
          hintElement = elem.find('.ui-select-choices').css({ opacity: 0 });
          $timeout(controlHint);
        }
      });
    }
  }
});