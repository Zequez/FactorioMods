$(document).on 'page:change', ->
  $('.multi_datalist').each (i, el)->
    $el = $(el)
    $input = $el.find('input')
    $datalist = $el.find('datalist')

    initialOptions = []
    initialOptionsValues = []
    for option in $datalist.children()
      initialOptions.push option
      initialOptionsValues.push option.value

    separator = $input.attr('separator')
    separatorRegex = new RegExp(".*#{separator}\\s*")

    $input.on 'textInput input change', (ev)->
      listPrepend = $input.val().match(separatorRegex)
      listPrepend = if listPrepend then listPrepend[0] else ''
      $datalist.remove()
      for option, i in initialOptions
        option.value = listPrepend + initialOptionsValues[i]
      $datalist.appendTo $el
      null
