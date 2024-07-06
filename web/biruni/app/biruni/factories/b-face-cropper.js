biruni.factory('bFaceCropper', function ($rootScope, $timeout, bConfig, bRoutes, bRequire) {
  bRequire.load('cropper');

  var $modal = $('#biruniFaceCropper');
  var $photo = $modal.find('.crop_face_photo');
  var cropboxZoomDist = 5;
  var cropboxMoveDist = 2;
  var onCrop = () => {};
  var isRounded = false;
  var isFaceShaped = false;

  var p = {};
  p.file_name = null;
  p.file_type = null;
  p.file_src = null;
  p.cropper = null;
  p.open = open;
  p.crop = crop;
  p.imageRotate = imageRotate;
  p.close = close;
  p.onKeyDown = onKeyDown;

  bConfig.onLocationChange(close);
  $photo.on('load', initCropper);

  function open($file, onCropCallBack = () => {}, rounded = false, faceShaped = false) {
    if (!$file) return;
    destroyCropper();
    p.file_name = $file?.name || String(moment().format('DD-MM-YYYY-hh-mm-ss')) + '.jpg';
    p.file_type = $file?.type && /image/.test($file.type) ? 'image' : 'none';
    p.file_src = $file?.sha ? bRoutes.LOAD_FILE + '?sha=' + $file.sha : URL.createObjectURL($file);
    onCrop = onCropCallBack;
    isRounded = rounded;
    isFaceShaped = faceShaped;
    $modal.fadeIn(200).addClass('opened').focus();
    $modal.blur(() => $modal.focus());
  }

  function close() {
    $modal.removeClass('opened').fadeOut(200);
    destroyCropper();
    p.file_name = null;
    p.file_type = null;
    p.file_src = null;
    onCrop = () => {};
  }

  function initCropper() {
    if (!p.file_type == 'image') return;
    p.cropper = new Cropper($photo[0], {
      viewMode: 0,
      dragMode: 'move',
      aspectRatio: 1 / 1,
      checkOrientation: false,
      guides: false,
      center: false,
      background: false,
      autoCropArea: 0.5,
      movable: true,
      rotatable: true,
      wheelZoomRatio: 0.1, // default value
      cropBoxMovable: true,
      cropBoxResizable: true,
      toggleDragModeOnDblclick: false,
      ready: function () {
        $('.point-e, .point-n, .point-w, .point-s').remove();
        $('.cropper-point').css({ 'height': '12px', 'width': '12px', 'margin': '-5px' });
        $('.cropper-drag-box.cropper-move.cropper-modal').css({ 'opacity': '.4' });
        let style = {};
        if (isRounded) {
          style['border-radius'] = '50%';
        }
        if (isFaceShaped) {
          style['opacity'] = '1';
          style['background-color'] = 'unset';
          style['background-image'] = `url('data:image/svg+xml;utf8,${encodeURIComponent( '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" viewBox="0 0 512.00 512.00" xml:space="preserve"><defs><mask id="face"><rect x="0" y="0" width="512.00" height="512.00" fill="white"/><path fill="black" d="M359.812,435.662c-19.166-7.168-40.989-26.526-40.989-40.965c0-9.559,0-21.502,0-37.885 c12.287-13.647,30.718-33.79,36.861-68.603c14.335-5.12,22.526-13.311,32.766-49.148c10.895-38.165-16.383-36.861-16.383-36.861 s0-20.478,0-38.221c0-30.038-13.983-118.775-116.055-118.775c-102.056,0-116.039,88.737-116.039,118.775 c0,17.742,0,38.221,0,38.221s-27.278-1.304-16.383,36.861c10.224,35.837,18.415,44.028,32.75,49.148 c6.144,34.813,24.59,54.956,36.877,68.603c0,16.382,0,28.326,0,37.885c0,14.439-23.566,34.822-40.989,40.965 c-28.062,9.895-98.04,16.871-115.319,76.338h438.181C457.749,452.701,387.666,446.086,359.812,435.662z"></path></mask></defs><rect x="0" y="0" width="512.00" height="512.00" fill="#2773c0" fill-opacity="0.35" mask="url(#face)"></rect></svg>' )}')`;
          style['background-position'] = 'center';
          style['background-size'] = 'contain';
          style['background-repeat'] = 'no-repeat';
        }
        $('.cropper-view-box, .cropper-face').css(style);
      },
    });
  }

  function destroyCropper() {
    if (!p.cropper) return;
    p.cropper.destroy();
    $photo.removeAttr('src');
  }

  function crop() {
    if (!p.cropper) return close();
    p.cropper.getCroppedCanvas().toBlob(blob => {
      let photo = new File([blob], p.file_name, { lastModified: Date.now(), type: blob.type });
      photo.size = blob.size;
      photo.$ngfBlobUrl = URL.createObjectURL(photo);
      onCrop(photo);
      close();
      $timeout(() => $rootScope.$digest());
    }, 'image/jpeg', 0.6);
  }

  function imageRotate(degree) {
    if (!p.cropper) return;
    p.cropper.rotate(degree);
  }

  function cropboxZoom(zAxis, moveFaster = false) {
    if (!p.cropper) return;
    let data = p.cropper.getCropBoxData();
    let dist = moveFaster ? zAxis * 10 : zAxis;
    p.cropper.setCropBoxData({
      width: data.width + dist,
      height: data.height + dist,
      left: data.left - dist / 2,
      top: data.top - dist / 2,
    });
  }

  function cropboxMove(xAxis, yAxis, moveFaster = false) {
    if (!p.cropper) return;
    let data = p.cropper.getCropBoxData();
    data.left += moveFaster ? xAxis * 20 : xAxis;
    data.top += moveFaster ? yAxis * 20 : yAxis;
    p.cropper.setCropBoxData(data);
  }

  function onKeyDown($event) {
    const kc_escape = 27;
    const kc_enter = 13;
    const kc_bracketleft = 219;
    const kc_bracketright = 221;
    const kc_arrowup = 38;
    const kc_arrowdown = 40;
    const kc_arrowleft = 37;
    const kc_arrowright = 39;

    if (!_.contains([kc_escape, kc_enter, kc_bracketleft, kc_bracketright, kc_arrowup, kc_arrowdown, kc_arrowleft, kc_arrowright], $event.keyCode)) return;

    $event.preventDefault();
    $event.stopPropagation();

    switch ($event.keyCode) {
      case kc_escape: close(); break;
      case kc_enter: crop(); break;
      case kc_bracketleft: cropboxZoom(-cropboxZoomDist, $event.altKey || $event.ctrlKey); break;
      case kc_bracketright: cropboxZoom(cropboxZoomDist, $event.altKey || $event.ctrlKey); break;
      case kc_arrowup: cropboxMove(0, -cropboxMoveDist, $event.altKey || $event.ctrlKey); break;
      case kc_arrowdown: cropboxMove(0, cropboxMoveDist, $event.altKey || $event.ctrlKey); break;
      case kc_arrowleft: cropboxMove(-cropboxMoveDist, 0, $event.altKey || $event.ctrlKey); break;
      case kc_arrowright: cropboxMove(cropboxMoveDist, 0, $event.altKey || $event.ctrlKey); break;
    }
  }

  return p;
});
