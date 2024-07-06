biruni.directive('bWhenScrolled', function () {
    return {
        restrict: 'A',
        scope: true,
        link: function (scope, elm, attr) {
            let raw = elm[0];
            if (attr.bWhenScrolled) {
                function run() {
                    if (raw.scrollTop + raw.offsetHeight >= 0.95 * raw.scrollHeight) {
                        scope.$apply(attr.bWhenScrolled);
                    }
                }

                elm.bind('scroll', run);
                elm.bind('touchmove', run);
            }
        }
    }
});
