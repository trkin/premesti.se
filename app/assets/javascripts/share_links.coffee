window.fb_share = (el) ->
  shareUrl = el.dataset.shareUrl
  alert 'Please provide data-share-url' unless shareUrl
  fbSharerUrl = "http://www.facebook.com/sharer/sharer.php?s=100&p[url]=" + encodeURI(shareUrl)
  # I usually provide just a link and let facebook get and cache the page
  if imageUrl = el.dataset.imageUrl
    fbSharerUrl += "&p[images][0]=" + encodeURI(imageUrl)
  if title = el.dataset.title
   fbSharerUrl += "&p[title]=" + encodeURI(title)
  if summary = el.dataset.summary
    fbSharerUrl += "&p[summary]=" + encodeURI(summary)

  window.open fbSharerUrl, 'facebook-share-dialog', 'width=626,height=436'

