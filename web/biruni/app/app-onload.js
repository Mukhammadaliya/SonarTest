(function () {
  if ('localStorage' in window && window['localStorage'] !== null) {
    let lang = JSON.parse(window.localStorage.getItem('session_lang')) || { code: '' };
    if (lang.code) {
      $.ajaxSetup({
        headers: { lang_code: lang.code },
      });
    }
  }

  if (/\?.*-mobile=true.*$/.test(window.location.hash)) {
    $(document).ready(function () {
      $(document).find('body').find('#kt_header').remove();
      $(document).find('body').find('#kt_header_mobile').remove();
      $(document).find('body').find('#kt_footer').remove();
      $(document).find('body').find('#kt_wrapper').css('padding-top', '12.5px');
      $(document).find('.subheader').remove();
    });

    if (/\?.*-lang_code=.*$/.test(window.location.hash)) {
      let params = new URLSearchParams(window.location.hash.split('?')[1]);
      let lang_code = params.get('-lang_code');

      if (lang_code) {
        $.ajaxSetup({
          headers: { lang_code: lang_code },
        });
      }
    }

    window.sessionPromise = $.post('b/core/m:session', { with_menu: 'N' });
  } else {
    window.sessionPromise = $.post('b/core/m:session');
  }

  window.onSessionResolve = new Promise(resolve => (window.sessionResolver = resolve));
})();

window.onbeforeunload = function () {
  window.scrollTo(0, 0);
};
