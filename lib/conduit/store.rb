require 'lupo'

module Conduit
  class Store
    include Lupo.enumerable(:persistence)

    # TODO: use named arguments
    def initialize(persistence, clock = Time)
      @persistence = persistence
      @clock       = clock
    end

    def put(name:, aggregate_id:, data: {})
      to_event @persistence.put(name: name, aggregate_id: aggregate_id, data: data, recorded_at: @clock.now)
    end

    def get(aggregate_id:, since: nil)
      to_events @persistence.get(aggregate_id: aggregate_id, since: since)
    end

    def all
      to_events @persistence.all
    end

    def count
      @persistence.count
    end

    private

    def to_events(records)
      records.map { |record| to_event(record) }
    end

    def to_event(record)
      Event.new(record)
    end
  end
end
