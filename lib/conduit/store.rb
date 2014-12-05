module Conduit
  class Store
    def initialize(persistence)
      @persistence = persistence
    end

    def put(name:, aggregate_id:, data: {})
      @persistence.put(name: name, aggregate_id: aggregate_id, data: data)
    end

    def get(aggregate_id:)
      @persistence.get(aggregate_id: aggregate_id)
    end

    def all
      @persistence.all
    end

    def count
      @persistence.count
    end
  end
end
