class Result
  attr_accessor :message, :data

  # you can return in service like:
  #   return Result.new 'Next task created', next_task: next_task
  # and use in controller:
  #   if result.success? && result.data[:next_task] == task
  def initialize(message, data = {})
    @message = message
    @data = data
  end

  def success?
    true
  end
end
