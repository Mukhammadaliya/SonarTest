biruni.directive('bAction', function () {
  return {
    restrict : 'E',
    require : '^bGrid',
    compile : function (el) {
      const html = el.html();
      return function (scope, el, attr, ctrl) {
        ctrl.grid.setActionHtml(html);
      }
    }
  };
});
