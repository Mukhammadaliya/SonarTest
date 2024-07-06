biruni.directive('bMaxlength', function() {

  function link(scope, elem, attr) {
    var threshold = 5;

    if (elem.attr('b-number') != undefined) {
      threshold = 0;
    }

    elem.attr('maxlength', attr.bMaxlength);
    elem.maxlength({
      alwaysShow: false,
      threshold: threshold,
      warningClass: "badge badge-danger",
      limitReachedClass: "badge badge-danger",
      twoCharLinebreak: false
    });
  }

  return {
    restrict: 'A',
    scope: true,
    link: link
  }
});