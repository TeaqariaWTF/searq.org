# frozen_string_literal: true

module FeedManager
  class Update < ApplicationService
    attr_reader :feed

    def initialize(feed:)
      @feed = feed
    end

    def call
      update_feed
    end

    private

    def update_feed
      entries.each do |entry|
        ItemManager::Create.new(feed:, entry:).call
      end

      feed
    end

    def entries
      result = Entries.new(feed:).call

      result.select do |entry|
        entry.published >= feed.items.last.published_at
      end
    end
  end
end
