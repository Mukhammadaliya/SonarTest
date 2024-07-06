biruni.directive('bCropper', function($parse, $templateCache, $compile, bRequire, bConfig) {

  function ctrl($scope, $attrs) {
    bRequire.load('cropper');
  }

  function link(scope, elem, attr, ctrl) {
    const o = {},
        photoSetter = $parse(attr.bCropper).assign,
        onSelect = $parse(attr.onSelect),
        crop_id = _.uniqueId('cropper'),
        template = $templateCache.get('b-cropper.html'),
        $parent = scope.page.$content;

    o.no_photo = 'page/resource/core/no_image.png';
    o.square = attr.square != 'false';
    o.round = attr.round != 'false';

    $parent.append($compile(`<form name="${crop_id}">${template}</form>`)(scope));

    const $modal = $parent.find(`form[name="${crop_id}"]`).find('.modal');

    function destroyCropper() {
      if (o.cropper) {
        o.cropper.destroy();
        $modal.find('.crop_main_photo').removeAttr('src');
      }
    }

    function uploadPhoto($file) {
      if ($file) {
        o.photo = $file;
        destroyCropper();
      }
      $modal.find('b-dropzone').scope().$bDropzone.clear();
    }

    function showModal() {
      $modal.modal('show');
    }

    function closeModal() {
      $modal.modal('hide');
      destroyCropper();
      o.photo = undefined;
    }

    function setCordinates(event, key, width) {
      let imgWidth = (width * o.cropper.getImageData().naturalWidth / event.detail.width).toFixed(4);
      let coef = (event.detail.width / width).toFixed(4);

      $modal.find('.' + key).css({
        'width': (imgWidth) + 'px',
        'margin-left': '-' + Math.abs((event.detail.x / coef).toFixed(4)) + 'px',
        'margin-top': '-' + Math.abs((event.detail.y / coef).toFixed(4)) + 'px'
      });
    }

    function changePhoto() {
      const image = $modal.find('.crop_main_photo')[0];
      const cropper = new Cropper(image, {
        aspectRatio: o.square ? 1/1 : NaN,
        viewMode: 1,
        crop(event) {
          setCordinates(event, 'crop_large', 100);
          setCordinates(event, 'crop_medium', 60);
          setCordinates(event, 'crop_small', 35);
        },
        movable: false,
        guides: false,
        rotatable: false,
        checkOrientation: false,
        zoomable: false,
        background: false,
        center: false,
        ready() {
          if(o.round) {
            $('.cropper-view-box, .cropper-face').css({'border-radius': '50%'});
          }
        }
      });
      o.cropper = cropper;
    }

    function saveCrop() {
      if (o.cropper && o.photo) {
        let file, name;
        name = _.isUndefined(o.photo.name) ? String(moment) + '.jpg' : o.photo.name; 
        o.cropper.getCroppedCanvas().toBlob(function(blob) {
          file = new File([blob], name, {lastModified: moment(), type: blob.type});
          scope.$apply(x => {
            photoSetter(scope, file);
            if (onSelect) onSelect(scope, { $file: file });
          });
          closeModal();
        }, attr.extension || 'image/jpeg', 0.6);
      } else {
        scope.$apply(x => {
          photoSetter(scope, undefined);
          if (onSelect) onSelect(scope, { $file: undefined });
        });
        closeModal();
      }
    }

    $modal.find('.crop_main_photo').on('load', function() {
      changePhoto();
    });

    elem.on('click', showModal);

    o.bConfig = bConfig;
    o.uploadPhoto = uploadPhoto;
    o.saveCrop = saveCrop;
    o.closeModal = closeModal;
    scope.o = o;
  }

  return {
    restrict: 'A',
    scope: true,
    link: link,
    controller: ctrl
  }
});