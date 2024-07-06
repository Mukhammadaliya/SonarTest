biruni.directive('bHotkey', function() {

  function link(scope, elem, attr) {
    var standart = {
      add: 'alt+a',
      edit: 'alt+e',
      save: 'alt+s',
      finish: 'ctrl+enter',
      refresh: 'alt+r',
      close: 'alt+q',
      delete: 'alt+d'
    };

    scope.page.bindHotkey(standart[attr.bHotkey] || attr.bHotkey, function() {
      if (!elem.prop('disabled') && elem.is(':visible')) {
        elem.trigger('click');
      }
    });
  }

  return {
    restrict : 'A',
    link: link,
    scope: true
  }
});
