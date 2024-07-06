(function($) {
  $.fn.hScroll = function(dependent) {
    var interval = 12,
        scrollableElems = this,
        headerHeight = $('body').find('#m_header').height();

    $(document).on('scroll', onscroll);

    function onscroll() {
      scrollableElems.each(earsPosition);
    }

    function earsPosition(i, scrollable) {
      $(scrollable).next().next().css('right', Math.max(scrollable.offsetWidth - scrollable.clientWidth - 2, 0));

      let top, height, rect = scrollable.getBoundingClientRect();
      if (window.innerHeight < scrollable.offsetHeight) {
        if (headerHeight < rect.top && rect.top < window.innerHeight) {
          top = 0;
          height = window.innerHeight - rect.top;
        } else if (headerHeight < rect.bottom && rect.bottom < window.innerHeight) {
          top = scrollable.offsetHeight - (rect.bottom - headerHeight);
          height = rect.bottom - headerHeight;
        } else if (rect.top < headerHeight && rect.bottom >= window.innerHeight) {
          top = -1 * rect.y + headerHeight;
          height = window.innerHeight - headerHeight;
        } else return;
        $(scrollable).parent().find('.h-ear').stop(null, true).animate({ 'top': top, 'height': height }, 50);
      }
    }

    scrollableElems.each(function(i, scrollable) {
      var $scrollable = $(scrollable);

      $scrollable.wrap('<div class="h-parent-scrollable"></div>');
      $scrollable.css('overflow-x', 'auto');

      let leftEar = $('<div class="h-ear h-left-ear"></div>');
      let rightEar = $('<div class="h-ear h-right-ear"></div>');
      let leftEarIcon = $('<span class="h-left-ear-icon"></span>').append('<i class="fas fa-chevron-left"></i>');
      let rightEarIcon = $('<span class="h-right-ear-icon"></span>').append('<i class="fas fa-chevron-right"></i>');

      leftEar.hover(scrollLeft).append(leftEarIcon);
      rightEar.hover(scrollRight).append(rightEarIcon);

      var scroll;

      function controlEars() {
        let left = !!scrollable.scrollLeft;
        let right = Math.floor(scrollable.scrollWidth - scrollable.scrollLeft) > scrollable.offsetWidth;

        leftEar.css({ visibility: left ? 'visible' : 'hidden', opacity: +left });
        rightEar.css({ visibility: right ? 'visible' : 'hidden', opacity: +right });
      }

      if (dependent && dependent.length) {
        scroll = function() {
          controlEars();
          dependent.each((x, elem) => elem.scrollLeft = scrollable.scrollLeft);
        }
      } else {
        scroll = controlEars;
      }

      function resize() {
        scroll();
        earsPosition(i, scrollable);
      }

      function scrollLeft() {
        if (!leftEar.is(':hover') || !scrollable.scrollLeft) {
          return;
        }
        scrollable.scrollLeft -= interval;
        setTimeout(scrollLeft, 10);
      }

      function scrollRight() {
        if (!rightEar.is(':hover') || scrollable.scrollWidth - scrollable.scrollLeft <= $scrollable.width()) {
          return;
        }
        scrollable.scrollLeft += interval;
        setTimeout(scrollRight, 10);
      }

      $scrollable.scroll(scroll).resize(resize).parent().append(leftEar).append(rightEar);

      scrollable.addEventListener('DOMNodeRemovedFromDocument', function() {
        $(document).off('scroll', onscroll);
      }, false);
    });
    return this;
  }
})(jQuery);