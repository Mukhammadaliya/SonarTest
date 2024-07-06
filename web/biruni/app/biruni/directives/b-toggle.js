biruni.directive('bToggle', function (bConfig, $parse, $templateCache, $compile, $timeout) {

  function link(scope, elem, attr, ngModel) {
    var container = attr.container;

    if (container) {
      if (!container.startsWith('body')) container = 'b-page:last-child ' + container;
    } else {
      container = 'b-page:last-child';
    }

    function compile(popover) {
      elem.on('inserted.bs.popover', function(){
        $compile(popover.tip)(scope);
      });
      elem.on('remove', function () {
        $(this).popover('dispose');
      });
    }

    if (attr.bToggle === 'popover') {
      $timeout(function() {
        elem.popover();
        compile(elem.data()["bs.popover"]);
      });
    } else if (attr.bToggle === 'tooltip') {
      $timeout(function() {
        elem.tooltip();
        elem.on('remove', function () {
          $(this).tooltip('dispose');
        });
      });
    } else {
      var c = {};

      c.clickYes = _.partial($parse(attr.onClickYes), scope);
      c.clickNo = _.partial($parse(attr.onClickNo), scope);

      scope._$toggle = c;

      var langs = bConfig.langs,
          temp = $templateCache.get('b-mini-confirm.html');

      var content = _.template(temp)({
        yesText : attr.yesText || langs.yes,
        yesBtnClass : attr.yesBtnClass || 'btn btn-default',
        yesIconClass : attr.yesIconClass || '',
        noText : attr.noText || langs.no,
        noBtnClass : attr.noBtnClass || 'btn btn-default',
        noIconClass : attr.noIconClass || ''
      });

      elem.popover({
        title : function(){
          return $(this)[0].dataset.title;
        },
        content : content,
        container : container,
        delay : {'show' : 0, 'hide' : 200},
        html : eval(attr.html || true),
        placement : attr.placement || 'left',
        viewport : {'selector' : attr.viewport || '.page-content', 'padding' : 10},
        trigger : attr.trigger || 'focus'
      });

      compile(elem.data()["bs.popover"]);
    }

    scope.$on('$destroy', function() {
      if (attr.bToggle === 'tooltip') {
        elem.tooltip('hide');
      } else {
        elem.popover('hide');
      }
    });
  }

  return {
    restrict : 'A',
    scope : true,
    link : link
  };
});
