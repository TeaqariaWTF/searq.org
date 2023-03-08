# frozen_string_literal: true

module FeedJob
  class Store
    include Sidekiq::Job

    def perform(task_id)
      task = Task.find(task_id)
      task.processing!

      feed = task.feed

      Timeout.timeout(5.minutes.in_seconds) do
        FeedManager::Store.new(feed:).call
      end

      feed.synchronized_at = Time.current
      feed.save

      task.succeeded!
      task.id
    rescue ActiveRecord::RecordNotFound => e
      raise e
    rescue StandardError => e
      task.error_message = { message: e.message }
      task.failed!
      task.save
      raise e
    end
  end
end
