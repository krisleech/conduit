require 'lupo'

module Conduit
  module Persistence
    class InMemory
      include Lupo.enumerable(:all)

      def initialize
        @data = {}
      end

      def put(name: , aggregate_id:, data: {}, recorded_at:)
        @data[aggregate_id] ||= []
        @data[aggregate_id].push({ name: name, aggregate_id: aggregate_id, data: data, recorded_at: recorded_at })
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
