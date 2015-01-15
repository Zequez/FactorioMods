$(document).on 'page:change', ->
  # Mods#show thumbnails hover
  # do ->
  #   modImages = $('.mod-images')
  #   if modImages.length
  #     new ModImages(modImages)

  # mods#show
  # Images galleries
  # do ->
  #   for gallery in $('.mod-medium-images [src], .mod-thumb-images [src]')
  #     do (gallery = $(gallery))->
  #       imagesSrc = (link.href for link in gallery.find('a'))
  #       $(gallery).on 'click', 'a', (ev)->
  #         if ev.button == 0 and not (ev.altKey || ev.shiftKey || ev.ctrlKey)
  #           ev.preventDefault()
  #           currentSrc = ev.currentTarget.href
  #           console.log currentSrc
  #           ImageModal.setImages(imagesSrc, imagesSrc.indexOf(currentSrc), ev)

  # mods#show
  # Imagemover for missing images mod-thumbnail
  # do ->
  #   $('[image-mover]').each (i, elem)->
  #     new ImageMover elem, elem.firstElementChild

  # # Version filter query maker
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

  # Edit mod mod version on fieldset legend
  do ->
    form = $('.mods-edit')
    if form.length
      setFieldsetLegend = ->
        $this = $(this)
        $legend = $(this).closest('fieldset').children('legend')

        initialMessage = $legend.data('initialMessage')
        if not initialMessage
          initialMessage = $legend.text()
          $legend.data('initialMessage', initialMessage)

       
        if this.value
          $legend.text(initialMessage + ' / ' + this.value)
        else
          $legend.text(initialMessage)

      inputs =  $('.mods-edit .string.input input')
      inputs.each setFieldsetLegend
      $(document).on 'keyup', '.mods-edit .string.input input', setFieldsetLegend
      $(document).one 'page:change', ->
        $(document).off 'keyup', '.mods-edit .string.input input', setFieldsetLegend


  # Edit mod textarea expansion
  # do ->
  #   li = $('#mod_description_input')
  #   input = li.find('textarea')
  #   input.focus(-> li.addClass('focused')).blur(-> li.removeClass('focused'))