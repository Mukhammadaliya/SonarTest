String.prototype.toMoment = function(format) {
  format = format || 'DD.MM.YYYY';
  var result = moment(this.valueOf(), format);
  return result._isValid ? result : null;
};
