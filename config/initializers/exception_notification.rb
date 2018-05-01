require 'exception_notification/rails'

class Notify
  def self.message(message, data = nil)
    ExceptionNotifier.notify_exception(Exception.new(message), data: data)
  end

  def self.exception_with_env(exception, args)
    # set env to nil if you do not want sections: Request, Environment, Session
    # backtrace is not shown for manual notification (only if data section
    # contains backtrace)
    # data section is always shown if exists
    params = {
      env: args[:env],
      exception_recipients: args[:exception_recipients],
      email_prefix: args[:email_prefix],
      data: args[:data],
    }.delete_if { |_k, v| v.nil? }
    ExceptionNotifier.notify_exception(exception, params)
  end
end

# rubocop:disable Metrics/BlockLength
if (receivers = Rails.application.secrets.exception_recipients).present?
  ExceptionNotification.configure do |config|
    # Ignore additional exception types. Those are already included
    # ActiveRecord::RecordNotFound
    # AbstractController::ActionNotFound
    # ActionController::RoutingError
    config.ignored_exceptions += %w[
      ActiveRecord::RecordNotFound
      AbstractController::ActionNotFound
      ActionController::RoutingError
      ActionController::UnknownFormat

      ApplicationController::NotFoundError
      ApplicationController::DisabledError
      ApplicationController::AccessDeniedError
      ApplicationController::InvalidCharactersUsed
    ]

    # Adds a condition to decide when an exception must be ignored or not.
    # The ignore_if method can be invoked multiple times to add extra conditions
    # config.ignore_if do |exception, options|
    #   not Rails.env.production?
    # end

    # Ignore crawlers
    IGNORE_HTTP_USER_AGENT = %w[
      Googlebot bingbot linkdexbot Baiduspider YandexBot panscient.com MJ12bot
      SeznamBot
    ].freeze
    config.ignore_if do |_exception, options|
      options[:env] && Array(IGNORE_HTTP_USER_AGENT).any? do |crawler|
        options[:env]['HTTP_USER_AGENT'] =~ Regexp.new(crawler)
      end
    end

    # Ignore formats
    IGNORE_HTTP_ACCEPT = %w[Agent-007 image/x-xbitmap].freeze
    config.ignore_if do |_exception, options|
      options[:env] && Array(IGNORE_HTTP_ACCEPT).any? do |format|
        options[:env]['HTTP_ACCEPT'] =~ Regexp.new(format)
      end
    end

    # Ignore too much notifications. throttle by same message
    THROTTLE_LIMIT = 3 # resets only when nothing is seen in interval window
    THROTTLE_INTERVAL_SECONDS = 1.hour
    config.ignore_if do |exception|
      # to exit from proc we could use 'next' ('return' or 'break' does not work
      # for proc) but than it returns nil, ie it will notify if true
      # to skip notification on development clear EXCEPTION_RECIPIENTS env
      cache_key = exception.message
      cache_key.sub!(/0[xX][0-9a-fA-F]+/, '') # ignore eventual object hex id
      already = Rails.cache.fetch(cache_key)
      if already
        Rails.cache.write cache_key,
                          already + 1,
                          expires_in: THROTTLE_INTERVAL_SECONDS
        # do not notify if already send max number of times, return val is true
        already >= THROTTLE_LIMIT
      else
        Rails.cache.write cache_key, 1, expires_in: THROTTLE_INTERVAL_SECONDS
        # it is ok to notify
        false
      end
    end

    # Ignore specific exceptions that are marked to be ignored
    # begin
    # rescue StandardError => e
    #   e.ignore_please = true
    #   raise e
    # end
    config.ignore_if(&:ignore_please)

    # Notifiers ================================================================

    # Email notifier sends notifications by email.
    config.add_notifier :email,
                        email_prefix: '[Premesti Se] ',
                        sender_address: Rails.application.secrets.mailer_sender,
                        exception_recipients: receivers.split(',')
  end
end
