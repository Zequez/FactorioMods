#= require active_admin/base
#= require jquery_ujs

$ ->
  loading = false
  $('#scrap-forum-posts')
  .on 'ajax:before', (ev)->
    if loading
      false
    else
      $(ev.target).find('.icon_spin').addClass 'rotate'
      loading = true
  .on 'ajax:success', (ev, data, status, xhr)->
    $(ev.target).find('.icon_spin').removeClass 'rotate'
    loading = false