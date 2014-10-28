class window.ImageModal
  visible: false
  imagesSrc: []
  currentImageIndex: 0
  openMouseEvent: null

  _init: ->
    if not @eModal
      @_findElements()
      @_bindEvents()

  setImages: (@imagesSrc, @currentImageIndex, openMouseEvent)->
    @_init()
    @_fillModal()
    @_open()
    @_createOrRecalculateMover(openMouseEvent)

  _open: ->
    if not @visible
      @eModal.show()
      @visible = true

  _close: ->
    if @visible
      @eModal.hide()
      @visible = false

  _findElements: ->
      @eModal = $('.image-modal').hide()
      @eModalCanvas  = @eModal.find('.image-modal-canvas')
      @eModalImg   = @eModal.find('.image-modal-img')
      # @eModalLink   = @eModal.find('.image-modal-link')
      @eModalClose = @eModal.find('.image-modal-close')
      @eModalArrows = @eModal.find('.image-modal-arrow')
      @eModalNext = @eModal.find('.image-modal-next')
      @eModalPrev = @eModal.find('.image-modal-prev')

      @eModalCloseList =  @eModal.add(@eModalCanvas).add(@eModalClose)
      @eModalForwardMousemoveList = @eModalClose.add(@eModalArrows)

  _bindEvents: ->
    @eModal.click =>
      @_close()

    @eModal.mousemove (ev)=> @imageMover.forwardMouseEvent(ev)

    @eModalImg.click (ev)=>
      @imageMover.toggleFit()
      ev.stopPropagation()

    @eModalNext.click (ev)=>
      @_nextImage()
      ev.stopPropagation()

    @eModalPrev.click (ev)=>
      @_prevImage()
      ev.stopPropagation()

  _nextImage: ->
    @currentImageIndex++
    if @currentImageIndex > @imagesSrc.length-1
      @currentImageIndex = 0
    @_fillModal()
    @_createOrRecalculateMover()

  _prevImage: ->
    @currentImageIndex--
    if @currentImageIndex < 0
      @currentImageIndex = @imagesSrc.length-1
    @_fillModal()
    @_createOrRecalculateMover()

  _setArrowsVisibility: ->
    @eModalArrows.toggle @imagesSrc.length != 1

  _createOrRecalculateMover: (openMouseEvent)->
    @_createImageMover(openMouseEvent) || @imageMover.recalculate(openMouseEvent)

  _createImageMover: (openMouseEvent)->
    return false if @imageMover
    @imageMover = new ImageMover(@eModalCanvas, @eModalImg, mouseEvent: openMouseEvent, bindMousemove: false)
    return true

  _fillModal: ->
    @eModalCanvas.attr 'href', @imagesSrc[@currentImageIndex]
    @eModalImg.attr 'src', @imagesSrc[@currentImageIndex]


window.ImageModal = new ImageModal