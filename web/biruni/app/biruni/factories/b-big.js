biruni.factory('bBig', function() {
  function parseRoundModel(patrm) {
    try {
      if (patrm.length !== 5) throw "round model length must be 5";
      let scale = parseFloat(patrm.substr(0,4));
      let tp = patrm.substr(4);
      if (patrm.substr(3,1) == '5') {
        scale -= 0.5;
      }

      return {
        scale: parseInt(scale),
        half: patrm.substr(3, 1) == '5',
        type: tp == 'R'? BigNumber.ROUND_HALF_UP: tp == 'C'? BigNumber.ROUND_CEIL: BigNumber.ROUND_FLOOR
      }
    } catch (e) {
      console.error("cannot parse round model");
      return {
        scale: 6,
        half: false,
        type: BigNumber.ROUND_HALF_UP
      }
    }
  }

  function bigNumber(patrm) {
    const big = BigNumber.clone();
    const ten = new big(10);
    var pattern = "+6.0R";
    var defrm = parseRoundModel(patrm || pattern);

    big.prototype.round = function(patrm) {
      var rm = defrm;
      if (arguments.length > 0) {
        rm = parseRoundModel(patrm);
      }

      function evalround(bval, rm) {
        if (rm.scale < 0) {
          let tens = ten.pow(-rm.scale);
          return bval.dividedBy(tens).dp(0, rm.type).multipliedBy(tens);
        }
        return bval.dp(rm.scale, rm.type);
      }

      if (rm.half) return evalround(this.multipliedBy(2), rm).dividedBy(2);
      return evalround(this, rm);
    }

    function round(value) {
      if (BigNumber.isBigNumber(value)) {
        return value.round().toString();
      } else {
        return new big(value).round().toString();
      }
    }

    function setRoundModel(rm) {
      if (arguments.length > 0) {
        pattern = rm;
        defrm = parseRoundModel(rm);
      } else return pattern;
    }

    function api(val) {
      return new big(val);
    }

    api.round = round;
    api.roundModel = setRoundModel;

    return api;
  }

  return bigNumber;
});