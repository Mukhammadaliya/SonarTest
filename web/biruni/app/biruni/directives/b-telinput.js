 biruni.directive('bTelinput', function (bRequire, bConfig, $timeout) {
  function link(scope, elem, attr, ctrl) {
    let initialCountry = attr.initialCountry;

    bRequire.load("intlTelInput",).then(function() {
      if (!initialCountry)
        initialCountry = bConfig.countryCode();

      initialCountry = initialCountry.toLowerCase();

      let iti = intlTelInput(elem[0], {
        formatOnDisplay: true,
        containerClass: 'd-block',
        showSelectedDialCode: true,
        initialCountry: initialCountry,
        countrySearch: false,
        nationalMode: false,
        utilsScript: 'assets/intl-tel-input/js/utils.js',
        preferredCountries: ['uz'],
      });

      if (ctrl) {
        ctrl.$validators.validNumber = function(value) {
          if (attr.required || value || elem[0].value.length > 0) {
            return iti.isValidNumber();
          } else {
            return true;
          }
        };

        ctrl.$parsers.push(function (value) {
          if (value) {
            $timeout(function() {
              iti.setNumber(value);
            });
          }
          return iti.getNumber();
        });

        ctrl.$formatters.push(function (value) {
          if (value) {
            if(value.charAt(0) !== '+') {
              value = '+' + value;
            }
            $timeout(function() {
              iti.setNumber(value);
              ctrl.$setViewValue(iti.getNumber());
            });
          }
        });
        
        elem.on("countrychange", function() {
          ctrl.$setViewValue(iti.getNumber());
        });

        ctrl.$processModelValue(); // called to apply new $formatters after
      }
    });
  }

  return {
    restrict : 'A',
    require : '?ngModel',
    link : link
  };
});
