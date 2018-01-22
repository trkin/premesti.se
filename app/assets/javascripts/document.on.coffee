$(document).on 'hidden.bs.modal', '.modal', ->
  $(this).removeData('bs.modal')
  console.log "remove boostrap modal"
