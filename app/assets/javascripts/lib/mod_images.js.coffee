class window.ModImages
  constructor: (@modImages)->
    @findElements()
    @bindEvents()
    @imageMovers = {}
    @generateImageMover(@mediumImages.index(@activeImage))

  findElements: ->
    @mediumImages = @modImages.find('.mod-medium-image')
    @thumbImages = @modImages.find('.mod-thumb-image')
    @mediumImagesContainers = @mediumImages.find('.mod-medium-image-container')
    @mediumImagesImg = @mediumImages.find('img')
    @activeImage = @mediumImages.filter('.active')

    # if @mediumImages.length == 0
    #   console.error '[ModImages] Could not find images'
    # if !(@mediumImages.length == @thumbImages.length == @mediumImagesContainers.length == @mediumImagesImg)
    #   console.error '[ModImages] Images count missmatch'
    #   console.table
    #     mediumImages: @mediumImages.length,
    #     thumbImages: @thumbImages.length,
    #     mediumImagesContainers: @mediumImagesContainers.length,
    #     mediumImagesImg: @mediumImagesImg.length
    # if @activeImage.length == 0
    #   console.log '[ModImages] No active image'



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
      imageLink =  $(@mediumImagesContainers[i])
      imageImg  = $(@mediumImagesImg[i])
      @imageMovers[i] = new ImageMover imageLink, imageImg