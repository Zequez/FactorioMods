class ImageMover
  triggerRecalculateOnLoad: false
  imageFitHeight: false
  imageFitWidth: false
  mouseX: null
  mouseY: null

  constructor: (@container, @image, options = {})->
    @container = $(@container)
    @image = $(@image)

    @options =
      mouseEvent: null
      bindMousemove: true
      fit: false
    $.extend(@options, options)

    @recalculate(@options.mouseEvent)
    @_bindEvents()

  recalculate: (mouseEvent)->
    @_readSizes()
    @_resizeImage()
    @_setPosition(mouseEvent)

  toggleFit: (fit)->
    fit ?= !@options.fit
    @options.fit = fit
    @recalculate()

  forwardMouseEvent: (mouseEvent)->
    @_setPosition(mouseEvent) if mouseEvent

  _readSizes: ->
    @containerWidth = @container.width()
    @containerHeight = @container.height()
    @imageWidth = @image.width()
    @imageHeight = @image.height()
    @xDiff = @imageWidth - @containerWidth
    @yDiff = @imageHeight - @containerHeight
    @rect = @container[0].getBoundingClientRect()
    @imageFitsX = @imageWidth < @containerWidth
    @imageFitsY = @imageHeight < @containerHeight
    @imageFitsNaturally = @imageFitsX and @imageFitsY

  _bindEvents: ->
    if @options.bindMousemove
      @container.on 'mousemove', (ev)=> @_setPosition(ev)

    $(window).on 'resize', => @recalculate()
    @image.on 'load', =>
      if @triggerRecalculateOnLoad
        @triggerRecalculateOnLoad = false
        @recalculate()

  _resizeImage: ->
    if @options.fit
      if (@imageWidth / @containerWidth) > (@imageHeight / @containerHeight)
        fitWidth = true
        fitHeight = false
      else
        fitWidth = false
        fitHeight = true
    else
      fitWidth = false
      fitHeight = false

    if @imageFitWidth != fitWidth or @imageFitHeight != fitHeight
      @image.css
        width:  if fitWidth then '100%' else ''
        height: if fitHeight then '100%' else ''

      @imageFitWidth  = fitWidth
      @imageFitHeight  = fitHeight

      @_readSizes()

  _setPosition: (ev)->
    @_parseMouseEvent(ev)

    if @_imageIsLoaded()
      if @mouseX and @mouseY and not @imageFitsNaturally
        x = @mouseX - @rect.left
        y = @mouseY - @rect.top
        xFrac = x / @containerWidth
        yFrac = y / @containerHeight

        xFrac = 0 if xFrac < 0
        xFrac = 1 if xFrac > 1
        yFrac = 0 if yFrac < 0
        yFrac = 1 if yFrac > 1

        translateX = -parseInt(if @imageFitsX then @xDiff/2 else xFrac*@xDiff)
        translateY = -parseInt(if @imageFitsY then @yDiff/2 else yFrac*@yDiff)

        @_translateImage(translateX, translateY)
      else
        @_translateImage(-parseInt(@xDiff/2), -parseInt(@yDiff/2))
    else
      @triggerRecalculateOnLoad =  true

  _parseMouseEvent: (ev)->
    if ev
      @mouseX = ev.clientX
      @mouseY = ev.clientY
      true
    else
      false

  _translateImage: (x, y)->
    elem = @image[0]

    transformString = "translate(#{x}px, #{y}px)"
    # console.log new Date, transformString

    elem.style.transform =
    elem.style.webkitTransform =
    elem.style.mozTransform =
    elem.style.msTransform = transformString

  _imageIsLoaded: ->
    not (!@image[0].complete || @image[0].naturalWidth == 0)


window.ImageMover = ImageMover