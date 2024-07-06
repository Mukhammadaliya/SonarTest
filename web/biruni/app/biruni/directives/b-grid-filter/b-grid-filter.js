biruni.directive('bFilter', function () {

  return {
    restrict : 'E',
    require : '^bGrid',
    link : {
      pre : function (scope, el, attr, ctrl) {
        ctrl.grid.addFilter(attr.name, attr.decorateWith, attr.checkboxLimit, attr.directive, attr.hasOwnProperty('extra'), attr.treeWithParent, attr.dateLevel);
      }
    }
  };
});
