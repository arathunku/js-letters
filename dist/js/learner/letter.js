// Generated by CoffeeScript 1.8.0
var Letter;

window.app.Letter = Letter = (function() {
  function Letter(letter, set) {
    this.set = set;
    this.char = letter;
    this.mi = math.zeros(this.set.numberOfFeatures, 1);
    this.cov = math.zeros(this.set.numberOfFeatures, this.set.numberOfFeatures);
    this.pi = 0;
    this.samples = [];
  }

  Letter.prototype.toString = function() {
    return this.char || '???!!! @@ WOA @@ !!!???';
  };

  Letter.prototype.push = function(points) {
    var $number;
    this.set.allSamples += 1;
    this.samples.push(points);
    $number = document.querySelector('#' + this.char + ' .number');
    return $number.innerText = parseInt($number.innerText, 10) + 1;
  };

  Letter.prototype.recalculate = function() {
    var mult, sample, substraction, _i, _j, _len, _len1, _ref, _ref1;
    this.mi = math.zeros(this.set.numberOfFeatures, 1);
    this.cov = math.zeros(this.set.numberOfFeatures, this.set.numberOfFeatures);
    this.pi = (this.samples.length / this.set.allSamples) * 1.0;
    _ref = this.samples;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sample = _ref[_i];
      this.mi = math.add(this.mi, sample);
    }
    mult = 1.0 / this.samples.length;
    this.mi = this.mi.map(function(value, index, matrix) {
      return value * mult;
    });
    _ref1 = this.samples;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      sample = _ref1[_j];
      substraction = math.subtract(sample, this.mi);
      this.cov = math.add(this.cov, math.multiply(substraction, math.transpose(substraction)));
    }
    mult = 1.0 / (this.samples.length - 1);
    return this.cov = this.cov.map(function(value, index, matrix) {
      return value * mult;
    });
  };

  Letter.prototype.start = function() {
    var sample, _i, _len, _ref, _results;
    _ref = window["letter_" + this.char];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      sample = _ref[_i];
      Learn.getMatrix(math.matrix(sample));
      this.push(Learn.getFeatures());
      _results.push(Learn.clean());
    }
    return _results;
  };

  return Letter;

})();

//# sourceMappingURL=letter.js.map