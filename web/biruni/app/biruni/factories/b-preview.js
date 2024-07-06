biruni.factory('bPreview', function (bConfig, bRoutes, bHttp, $sce) {
  let $pv = $('#biruniPreview');
  let p = {};

  bConfig.onLocationChange(close);

  p.open = open;
  p.close = close;
  p.rotateImage = rotateImage;
  p.scale = scale;

  let scaleValue = 1;
  let rotateValue = 0;
  resetImage();

  function resetImage() {
    p.file_name = '';
    p.file_type = '';
    p.file_src = '';
    p.download_link = '';
  }

  function resetLayout() {
    scale(0);
    rotateImage(0);
  }

  function rotateImage(r) {
    if (r === 0) {
      rotateValue = 0; //reset
    } else {
      rotateValue += r;
    }
    if (p.file_type === 'image') {
      $pv.find('img').css('transform', `rotate(${rotateValue}deg) scale(${scaleValue})`);
    } else {
      $pv.find('video').css('transform', `rotate(${rotateValue}deg) scale(${scaleValue})`);
    }
  }

  function scale(sc) {
    // increase
    if (sc === 1) {
      if (scaleValue >= 1) scaleValue += 0.5;
      else scaleValue *= 2;
    } else if (sc === -1) {
      if (scaleValue > 1) scaleValue -= 0.5;
      else scaleValue /= 2;
    } else {
      scaleValue = 1; // reset
    }

    if (p.file_type === 'image') {
      $pv.find('img').css('transform', `rotate(${rotateValue}deg) scale(${scaleValue})`);
    } else {
      $pv.find('video').css('transform', `rotate(${rotateValue}deg) scale(${scaleValue})`);
    }
  }

  function openOnlyoffice(file) {
    if (!file.sha) {
      p.file_type = 'none';
      return;
    }
    p.file_name = '';
    p.file_src = '';
    p.download_link = '';
    bHttp
      .postData(bRoutes.RUN_ONLYOFFICE, {
        sha: file.sha,
        embedded: file.embedded || 'Y',
      })
      .then(
        result => {
          const blob = new Blob([result.data], { type: 'text/html' });
          p.file_src = $sce.trustAsResourceUrl(URL.createObjectURL(blob));
        },
        err => {
          p.file_type = 'none';
        }
      );
  }

  function openMedia(file) {
    if (file.sha) {
      p.file_src = bRoutes.LOAD_FILE + '?sha=' + file.sha;
      p.download_link = bRoutes.DOWNLOAD_FILE + '?sha=' + file.sha;
    } else {
      p.file_src = p.download_link = URL.createObjectURL(file);
    }
  }

  function open(file) {
    p.file_name = file?.name;
    p.file_type = /image/.test(file.type)      ? 'image'      :
                  /video/.test(file.type)      ? 'video'      :
                  /onlyoffice/.test(file.type) ? 'onlyoffice' : 'none';

    switch(p.file_type) {
      case 'onlyoffice': openOnlyoffice(file); break;
      case 'image':
      case 'video': openMedia(file); break;
    }

    $pv.fadeIn(200).addClass('opened');
    resetLayout();
  }

  function close() {
    $pv.removeClass('opened').fadeOut(200);
    resetImage();
  }

  return p;
});
