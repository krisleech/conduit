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
      @persistence.get(aggregate_id: aggregate_id).map { |attributes| Event.new(attributes) }
    end

    def all
      @persistence.all
    end

    def count
      @persistence.count
    end
  end
end
