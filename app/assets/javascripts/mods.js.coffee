$(document).on 'page:change', ->
  # Mods#show thumbnails hover
  do ->
    thumbs = $('.mod-thumbnail')
    if thumbs.length
      thumbThumbsContainer = $('.mod-thumbnail-thumbnails')
      thumbThumbsContainer.on 'mouseover', (ev)->
        dataThumbOf = $(ev.target).attr('data-thumb-of')
        if dataThumbOf
          activeThumb = thumbs.filter("[data-thumb=\"#{dataThumbOf}\"]")
          thumbs.removeClass 'active'
          activeThumb.addClass 'active'

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
