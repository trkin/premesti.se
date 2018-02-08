$(document).on 'hidden.bs.modal', '.modal', ->
  $(this).removeData('bs.modal')
  console.log "remove boostrap modal"

$(document).on 'shown.bs.modal', '.modal', ->
  if this.innerHTML.indexOf('initialize_google') > -1
    initialize_google()
