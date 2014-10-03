window.app.Letter = class Letter
  constructor: (letter, set)->
    @set = set
    @char = letter
    @mi = math.zeros(@set.numberOfFeatures, 1)
    @cov = math.zeros(@set.numberOfFeatures, @set.numberOfFeatures)
    @pi = 0
    @samples = []

  toString: ->
    @char || '???!!! @@ WOA @@ !!!???'

  push: (points) ->
    @set.allSamples += 1
    @samples.push(points)
    $number = document.querySelector('#'+@char+' .number')
    $number.innerText = parseInt($number.innerText, 10) + 1;

  recalculate: ->
    @mi = math.zeros(@set.numberOfFeatures, 1)
    @cov = math.zeros(@set.numberOfFeatures, @set.numberOfFeatures)

    @pi = (@samples.length/@set.allSamples)*1.0

    for sample in @samples
      @mi = math.add(@mi, sample)

    mult = 1.0/@samples.length
    @mi = @mi.map (value, index, matrix) ->
      value * mult

    for sample in @samples
      substraction = math.subtract(sample, @mi)
      @cov = math.add( @cov,
        math.multiply( substraction, math.transpose(substraction) )
      )

    mult = 1.0/(@samples.length-1)
    @cov = @cov.map (value, index, matrix) ->
      value * mult


  start: ->
    for sample in window["letter_#{@char}"]
      Learn.getMatrix(math.matrix(sample))
      @push Learn.getFeatures()
      Learn.clean()




