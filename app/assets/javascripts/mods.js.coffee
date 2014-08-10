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


$(document).on 'page:change', ->
  # Mods#show thumbnails hover
  do ->
    modImages = $('.mod-images')
    if modImages.length
      new ModImages(modImages)

  # Images galleries
  do ->
    for gallery in $('.mod-medium-images, .mod-thumb-images')
      do (gallery = $(gallery))->
        imagesSrc = (link.href for link in gallery.find('a'))
        $(gallery).on 'click', 'a', (ev)->
          if ev.button == 0 and not (ev.altKey || ev.shiftKey || ev.ctrlKey)
            ev.preventDefault()
            currentSrc = ev.currentTarget.href
            console.log currentSrc
            ImageModal.setImages(imagesSrc, imagesSrc.indexOf(currentSrc), ev)

  # Imagemover for missing images mod-thumbnail
  do ->
    $('[image-mover]').each (i, elem)->
      new ImageMover elem, elem.firstElementChild



  # Version filter query maker
  do ->
    versionFilterInput = $('.version-filter-input')
    if versionFilterInput.length
      options = versionFilterInput[0].options
      versionFilterInput.on 'change', (ev)->
        index = versionFilterInput[0].selectedIndex
        Turbolinks.visit options[index].value

  # Search results highlighter
  do ->
    query = $('#search-input').val()
    if query
      # Escape for Regex
      regexQuery = query.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
      regexQuery = new RegExp(regexQuery, 'ig')
      for elem in $('.highlight-query')
        elem.innerHTML = elem.innerHTML.replace regexQuery, (match)->
          '<span class="query-highlight">'+match+'</span>'
      return
