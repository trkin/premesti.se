class TaskWithErrorJob < ApplicationJob
  queue_as :default
  def perform
    raise 'This is sample_error_in_sidekiq'
  end
end
