biruni.directive('bEditor', function ($parse, bRequire, bConfig, $timeout) {
  function link(scope, elem, attr, ctrl) {
    bRequire.load('ckeditor5').then(function() {
      var model = $parse(attr.model),
          setter = model.assign;

      function setData(editor) {
        setter(scope, editor.getData());
      }

      function launchEditor(editor) {
        $timeout(function() {
          editor.model.document.on('change:data', _ => {
            setData(editor)
          });

          scope.$watch(attr.model, function (newValue, oldValue) {
            if (newValue && !angular.equals(newValue, editor.getData())) {
              editor.setData(newValue);
            }
          });
        });
      }

      InlineEditor.create(elem[0], {
        toolbar: {
          items: [
            'undo',
            'redo',
            '|',
            'heading',
            '|',
            'bold',
            'italic',
            'underline',
            'strikethrough',
            '|',
            'fontColor',
            'alignment',
            '|',
            'bulletedList',
            'numberedList',
            'indent',
            'outdent',
            '|',
            'link',
            'imageUpload',
            'insertTable',
            'code',
            '|',
            'exportWord'
          ]
        },
        language: bConfig.langCode(),
        image: {
          toolbar: [
            'imageTextAlternative',
            'imageStyle:full',
            'imageStyle:side'
          ]
        },
        table: {
          contentToolbar: [
            'tableColumn',
            'tableRow',
            'mergeTableCells'
          ]
        }
      }).then(launchEditor).catch(error => {
        console.error(error);
      });
    });
  }

  return {
    restrict: 'E',
    link: link
  };
});
