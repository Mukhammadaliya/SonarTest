biruni.directive('bContentMaker', function(bRequire, bConfig, bContentMaker) {
  function link(scope, elem) {
    bRequire.load('ace', 'ace-mode-html', 'html2pdf').then(() => {
      var maker = bContentMaker();
      var editor = ace.edit(elem.find('.workspace .editor')[0], { mode: 'ace/mode/html' });
      editor.on('change', () => editor.curOp && editor.curOp.command.name ? scope.text = editor.getValue() : null);

      function run(type) {
        maker
          .render(scope.text, scope.data)
          .then(html => {
            if (type == 'pdf') {
              html2pdf(html);
              elem.find('.preview .content').html(html);
            } else if (type == 'tab') {
              let new_tab = window.open();
              new_tab.document.write(html);
              new_tab.focus();
            } else {
              elem.find('.preview .content').html(html);
            }
          });
      }

      scope.$watch('text', value => editor.setValue(value || ''));

      scope.langs = bConfig.langs;
      scope.run = run;
    });
  }

  return {
    restrict: 'E',
    scope: {
      text: '=',
      data: '='
    },
    link: link,
    templateUrl: 'b-content-maker.html'
  };
});