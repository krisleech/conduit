module Conduit
  module Persistence
    class InMemory
      def initialize
        @data = {}
      end

      def put(name: , aggregate_id:, data: {})
        @data[aggregate_id] ||= []
        @data[aggregate_id].push({ name: name, aggregate_id: aggregate_id, data: data })
      end

      def get(aggregate_id:)
        @data.fetch(aggregate_id, [])
      end

      def all
        @data.flat_map { |_, events| events }
      end

      def count
        all.reduce(0) { |count, event| count += 1 }
      end
    end
  end
end
