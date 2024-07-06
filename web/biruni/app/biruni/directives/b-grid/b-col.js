biruni.directive('bCol', function () {
  return {
    restrict : 'E',
    require : '^bGrid',
    link : {
      pre : function (scope, elem, attr, ctrl) {
        ctrl.grid.addCol({
          name: attr.name,
          size: attr.size ? attr.size : 1,
          asHtml: attr.asHtml,
          img: attr.img,
          sortBy: attr.sortBy,
          format: attr.format,
          scale: attr.scale ? parseInt(attr.scale) : undefined,
          align: attr.align,
          onClick: attr.onClick
        }, elem);
      }
    }
  };
});
