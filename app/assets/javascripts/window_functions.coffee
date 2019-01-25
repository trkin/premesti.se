window.enableRecaptchaButtons = (e) ->
  console.log 'enableRecaptchaButtons'
  $('[data-recaptcha-button]').prop('disabled', false)
