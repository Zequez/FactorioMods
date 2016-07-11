banner = document.getElementById('official-app-banner')
button = banner.querySelector('button')


showBanner = -> banner.style.display = 'block'
hideBanner = -> banner.style.display = 'none'

timeSinceLastDismissed = new Date().valueOf() - localStorage['dismissed-banner']

if !localStorage['dismissed-banner'] or timeSinceLastDismissed > 1000*60*60 # 1 hour
  showBanner()
  button.addEventListener 'click', ->
    localStorage['dismissed-banner'] = new Date().valueOf()
    hideBanner()
