app = window.app || {}
class Learn
  constructor: ->
    @$writeLetter = document.querySelector('.write .letter')
    @predicted = false;
    @currentSet = app.set
    letters = []
    for letter in @currentSet.letters
      letter = new app.Letter(letter, @currentSet)
      letters.push letter
    @currentSet.letters = letters


    document.querySelector('.current-set .info').innerText = @currentSet.letters.join(', ')
    @clean()

  start: ->
    for letter in @currentSet.letters
      letter.start()
    for letter in @currentSet.letters
      letter.recalculate()

  getMatrix: (matrix) ->
    if @matrix
      @matrix
    else
      @matrix = @getRealMatrix(matrix || window.canvas.getMatrix())

  predict: ->
    @predictions =  @predirectFromMatrix()
    max = math.max(@predictions)
    sum = 0
    for i in [0..@currentSet.letters.length-1]
      document.querySelector('#'+@currentSet.letters[i]+' .prediction').innerText = @predictions.get([i,0])
      sum += @predictions.get([i,0])
      if max == @predictions.get([i,0])
        @predictedLetter(@currentSet.letters[i])

    document.querySelector('.sum').innerText = "Sum: #{sum}"

  predictedLetter: (letter) ->
    document.querySelector('.recognize .letter').innerText = letter

  correct: (correct_letter, recalculate=1)->
    for letter in @currentSet.letters
      if letter.char == correct_letter
        letter.push(@getFeatures())

    if recalculate
      for letter in @currentSet.letters
        letter.recalculate()

    for element in document.querySelectorAll('.letters-element .prediction')
      element.innerText = "-"

    canvas.clean()
    @clean()

  clean: ->
    @matrix = null
    @predicted = null
    @features = null
    @printFeatures(math.zeros(@currentSet.numberOfFeatures))
    @predictedLetter('-')


  getMaxDims: (matrix) ->
    top = matrix.size()[1]
    bottom = 0
    right = 0
    left = matrix.size()[1]

    matrix.forEach (value, index, row) ->
      if value
        x = index[1]
        y = index[0]
        right = x if x >= right
        top = y if y <= top
        left = x if x <= left
        bottom = y if y >= bottom

    top: top
    bottom: bottom
    right: right
    left: left
    xLength: Math.abs(right-left)
    yLength: Math.abs(bottom-top)


  getRealMatrix: (matrix)->
    new_matrix = []
    dims = @getMaxDims(matrix)

    new_matrix = @crop matrix, dims

    dims: dims
    matrix: new_matrix

  crop: (matrix, borders) ->
    unless matrix
      matrix = @getMatrix().matrix

    new_matrix = []

    y = 0
    for row in matrix._data
      x = 0
      tmp = []
      if y >= borders.top && y <= borders.bottom
        for element in row
          if x >= borders.left && x <= borders.right
            tmp.push matrix.get([y, x])
          x += 1

      if tmp.length
        new_matrix.push tmp
      y += 1

    math.matrix(new_matrix)

  countPixels: (data)->
    pixels =
      positive: 0.0
      all: 1.0

    data.forEach (value, index, matrix) ->
      pixels.positive += 1.0 if value
      pixels.all += 1.0

    (pixels.positive/pixels.all)

  matrixPercentages: (options) ->
    data = @getMatrix().matrix

    {
      top: Math.round(data.size()[0] * options.top)
      right: Math.round(data.size()[1] * options.right)
      bottom: Math.round(data.size()[0] * options.bottom)
      left: Math.round(data.size()[1] * options.left)
    }
  ################# ABC  #########################
  feature1: ->
    smaller = @crop null, @matrixPercentages {top: 0, bottom: 1, left: 0, right: 0.3}
    dims = @getMaxDims(smaller)
    dims.yLength / smaller.size()[0]

  feature2: ->
    smaller = @crop null, @matrixPercentages {top: 0.4, bottom: 0.6, left: 0, right: 1}
    dims = @getMaxDims(smaller)
    dims.xLength / smaller.size()[1]
  ################# /ABCD  #########################

  getFeatures: ->
    if @features
      @features
    else
      features = []
      for i in [1..@currentSet.numberOfFeatures]
        feature = this['feature'+(i+@currentSet.move)]()
        features.push [feature]

      @features = math.matrix(features)
      @features

  norm: (features, mi, cov) ->
    substraction = math.subtract(features, mi)
    tmp = math.multiply( math.transpose(substraction), math.inv(cov) )

    expVal = math.multiply(tmp, substraction)

    expVal = expVal.get([0,0]) if expVal

    detCov = Math.abs(math.det(cov))

    1.0 / (Math.pow(2*3.14159265358, @currentSet.numberOfFeatures/2) * Math.sqrt(detCov) ) * Math.exp(-0.5 * expVal)

  predirectFromMatrix: (features=@getFeatures()) ->
    @printFeatures()
    predicted = math.zeros(@currentSet.letters.length, 1)
    i = 0
    norm = 0
    for letter in @currentSet.letters
      formula = @norm(features, letter.mi, letter.cov)
      norm += formula * letter.pi
      predicted.set([i, 0], letter.pi * formula)
      i += 1

    predicted = predicted.map (value, index, matrix) ->
      value / norm

    predicted

  printFeatures: (features=@getFeatures())->
    $elements = document.querySelectorAll ".features-element"
    i = 0
    features.map (value, index, matrix) ->
      $elements[i].innerText = value
      i += 1


window.onload = ->
  window.Learn = new Learn()
  window.Learn.start()
  Learn.correct()
