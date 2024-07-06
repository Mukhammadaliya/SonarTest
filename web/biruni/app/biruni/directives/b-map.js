biruni.directive('bMap', function () {

  function link(scope, elem, attr) {
    scope.bPage.getMap(attr.name, elem.find('iframe'));
  }

  return {
    required : 'E',
    link : link,
    template : function (elem, attr) {
      var width = attr.width ? attr.width : '100%';
      var height = attr.height ? attr.height : '100%';

      return '<iframe style="border: 0;overflow: auto;" width="' + width + '"  height="' + height + '" src="about:blank"></iframe>';
    }
  };
});
