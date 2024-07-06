biruni.directive('tdev', function () {

  function link (scope, elem, attr) {
    var bPage = scope.bPage;

    elem.click(function(ev){
      ev.stopPropagation();
      elem.find('.sub-menu').show();
      input.focus();
    });
    elem.find('label').text(attr.key);

    var input = elem.find('.form-control');
    var val = bPage.pureLangs[attr.key];

    input.val(val);

    input.on('blur', function(){
      elem.find('.sub-menu').hide();
    }).on('keydown', function(ev){
      if (ev.which == 27) {
        ev.stopPropagation();
      }
    }).on('change keyup paste', function(ev){
      if (ev.which == 27) {
        input.val(val);
      }
      bPage.pureLangs[attr.key] = input.val();
      bPage.langs[attr.key] = input.val();
      scope.updateTranslate();
    });
  }

  return {
    restrict : 'E',
    link : link,
    templateUrl: 'b-tdev.html'
  };
});
