class ModImages
  constructor: (@modImages)->
    @findElements()
    @bindEvents()
    @imageMovers = {}
    @generateImageMover(@mediumImages.index(@activeImage))

  findElements: ->
    @mediumImages = @modImages.find('.mod-medium-image')
    @thumbImages = @modImages.find('.mod-thumb-image')
    @mediumImagesLinks = @mediumImages.find('.mod-medium-image-link')
    @mediumImagesImg = @mediumImages.find('.mod-medium-image-img')
    @activeImage = @mediumImages.filter('.active')

  bindEvents: ->
    # Thumbnail switching
    for thumbImage, i in @thumbImages
      thumbImage = $(thumbImage)
      mediumImage = $(@mediumImages[i])
      do (mediumImage, i)=>
        thumbImage.on 'mouseover', =>
          @activateThumbnail(mediumImage, i)

  activateThumbnail: (mediumImage, i)->
    @activeImage.removeClass 'active'
    mediumImage.addClass 'active'
    @activeImage = mediumImage
    @generateImageMover(i)


  generateImageMover: (i)->
    if not @imageMovers[i]
      imageLink =  $(@mediumImagesLinks[i])
      imageImg  = $(@mediumImagesImg[i])
      @imageMovers[i] = new ImageMover imageLink, imageImg