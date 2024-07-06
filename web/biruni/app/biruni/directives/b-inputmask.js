biruni.directive('bInputmask', function (bRequire) {
  function link(scope, elem, attr) {
    var mask = attr.bInputmask;

    bRequire.load("inputmask").then(function() {
      if (!_.isEmpty(mask)) {
        elem.inputmask({
          mask: mask,
          autoUnmask: true,
          clearMaskOnLostFocus: false
        });
      } else {
        console.error("mask is empty");
      }
    });
  }

  return {
    restrict : 'A',
    require : '?ngModel',
    link : link
  };
});
