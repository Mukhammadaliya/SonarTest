biruni.directive('bDropzone', function($parse, $templateCache, $compile, bRequire, bConfig, $q) {

  function link(scope, elem, attr) {
    bRequire.load('compressor').then(() => {
      var $bDropzone = {
        files: [],
        clear: function() {
          this.files = [];
        }
      };

      var
      onSelect = $parse(attr.onSelect),
      modelSetter = attr.model ? $parse(attr.model).assign : '',
      quality = !_.isUndefined(attr.quality) ? attr.quality : 0.6,
      size = !_.isUndefined(attr.size) ? attr.size : 100000,
      template = _.template($templateCache.get('b-dropzone.html'))({
        drag_drop_text: attr.dragDropText || bConfig.langs.dz_drop_file,
        multiple: !_.isUndefined(attr.multiple) ? `ngf-multiple="true"` : '',
        keep: !_.isUndefined(attr.keep) ? `ngf-keep="true"` : '',
        accept: attr.accept ? `ngf-accept="${attr.accept}"` : ''
      });

      $(elem).append($compile(template)(scope));

      let matches = ['image/png', 'image/jpg', 'image/jpeg', 'image/png', 'image/webp', 'image/gif'];

      function uploadFile($files) {
        if ($files) {
          $q.all(_.map($files, x => {
            let promise = $q((resolve, reject) => {
              if(_.contains(matches, x.type)) {
                new Compressor(x, {
                  quality: quality,
                  convertTypes: ['image/png', 'image/jpg', 'image/jpeg', 'image/png', 'image/webp', 'image/gif'],
                  convertSize: size,
                  success(result) {
                    let oldSize = x.size;
                    let lastModified = x.lastModified;
                    if(oldSize != result.size) {
                      lastModified = moment();
                    }
                    x = new File([result], x.name, {lastModified: lastModified, type: result.type});
                    x.oldSize = oldSize;
                    resolve(x);
                  },
                  error(err) {
                    console.error(err.message);
                    reject(err);
                  }
                });
              } else {
                resolve(x);
              }
            })
            return promise;
          })).then((result) => {
            $files = result;
            $bDropzone.files = $files;
            var value = _.isUndefined(attr.multiple) ? _.first($files) : $files;

            if (onSelect) {
              onSelect(scope, { $file: value });
            }
            if (modelSetter) {
              modelSetter(scope, value);
            }
          })
        }
      }

      scope.$bDropzone = $bDropzone;
      scope.uploadFile = uploadFile;
    });
  }

  return {
    restrict: 'E',
    scope: true,
    link: link
  };
});
