$(document).on 'hidden.bs.modal', '.modal', ->
  $(this).removeData('bs.modal')
  console.log "remove boostrap modal"

$(document).on 'click', '[data-scroll-into-view]', (e) ->
  target = document.getElementById e.currentTarget.dataset.scrollIntoView
  if typeof target.scrollIntoView == 'undefined'
    # scrollIntoView not supported, so use link
    window.location.hash = e.currentTarget.dataset.scrollIntoView
  else
    e.preventDefault()
    target.scrollIntoView behavior: 'smooth'
    target.classList.add 'shake'

$(document).on 'click', '[data-toggle="modal"]', (e) ->
  console.log 'data-toggle="modal"'
  url = e.currentTarget.href
  targetModalId = e.currentTarget.dataset.target
  targetModalId = targetModalId.substring(1) if targetModalId.substring(0,1) == '#'

  modalBodyFooter = document.getElementById(targetModalId).getElementsByClassName("modal-body-footer")[0]
  fetch(
    url,
    credentials: 'same-origin'
  )
    .then (response) -> response.text()
    .then (html) ->
      # modalBodyFooter.innerHTML = html
      $(modalBodyFooter).html html
