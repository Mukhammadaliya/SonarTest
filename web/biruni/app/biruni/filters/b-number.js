biruni.filter('bNumber', function () {
  function allTrim(val) {
    return val.replace(/\s+/g, ' ').trim();
  }

  function formatNumber(val, scale, fill_with_zero) {
    if (!val) {
      return val;
    }

    val = allTrim(String(val));

    var sign = '';

    if (val[0] === '-') {
      sign = '-';
    }

    val = val.replace(/[^0-9.]/g, '').replace(/^[0]+/, '').split('.');

    var a = val[0],
        b = val[1] || '',
        k = a.length % 3;

    a = ((k ? a.substr(0, k) + ' ' : '') + a.substr(k).replace(/(\d{3})(?=\d)/g, '$1 ')).trim();

    if (a === '') {
      a = '0';
    }

    if (scale && b.length <= scale && fill_with_zero) {
      b = b.padEnd(scale, '0');
    } else {
      b = b.replace(/[0]+$/, '');
    }

    if (b.length) {
      val = a + '.' + b;
    } else {
      val = a;
    }

    return sign + val;
  }

  return formatNumber;
});