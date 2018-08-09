$(document).on 'turbolinks:load', ->
  chat_page = $('[data-chat-page]')
  return unless chat_page
  App.chat = App.cable.subscriptions.create {
      channel: 'ChatChannel',
      chat_id: chat_page.data('chatPage'),
    },
    connected: ->
      # Called when the subscription is ready for use on the server

    disconnected: ->
      # Called when the subscription has been terminated by the server

    received: (data) ->
      # Called when there's incoming data on the websocket for this channel
      $('#messages').prepend(data['message'])
