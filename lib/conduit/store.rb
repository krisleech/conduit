require 'lupo'

module Conduit
  class Store
    include Lupo.enumerable(:persistence)

    def initialize(persistence)
      @persistence = persistence
    end

    def put(name:, aggregate_id:, data: {})
      @persistence.put(name: name, aggregate_id: aggregate_id, data: data)
    end

    def get(aggregate_id:)
      to_events @persistence.get(aggregate_id: aggregate_id)
    end

    def all
      to_events @persistence.all
    end

    def count
      @persistence.count
    end

    private

    def to_events(records)
      records.map { |record| Event.new(record) }
    end
  end
end
