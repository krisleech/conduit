require 'spec_helper'

class InMemoryPersistence

  def initialize
    @data = {}
  end

  def put(name: , aggregate_id:, data: {})
    @data[aggregate_id] ||= []
    @data[aggregate_id] << Object.new
  end

  def count(aggregate_id: nil)
    if aggregate_id.nil?
      count = 0
      @data.each do |k,v| # FIXME: use reduce
        count += v.size
      end
      count
    else
      @data[aggregate_id].count
    end
  end
end

describe 'Conduit::EventStore::InMemoryPersistence' do
  let(:persistence) { InMemoryPersistence.new }

  describe 'initialization' do
    it 'has no data' do
      is(persistence.count).zero?
    end
  end

  describe '#put' do
    it 'persists the event' do

      persistence.put(name:        :thing_created,
                      aggregate_id: 1,
                      data:         { id: 1, name: 'Kris Leech' })

      expect(persistence.count(aggregate_id: 1)).to == 1


    end

    it 'persists multiple events for the same aggregate' do
      persistence.put(name:        :thing_created,
                      aggregate_id: 1,
                      data:         { id: 1, name: 'Kris Leech' })

      persistence.put(name:        :thing_updated,
                      aggregate_id: 1,
                      data:         { id: 1, name: 'Kris Leech' })

      expect(persistence.count(aggregate_id: 1)).to == 2

    end

    it 'persists multiple events for different aggregates' do
      persistence.put(name:        :thing_created,
                      aggregate_id: 1,
                      data:         { id: 1, name: 'Kris Leech' })

      persistence.put(name:        :thing_updated,
                      aggregate_id: 1,
                      data:         { id: 1, name: 'Kris Leech' })

      persistence.put(name:        :thing_updated,
                      aggregate_id: 2,
                      data:         { id: 1, name: 'Kris Leech' })

      expect(persistence.count).to == 3
    end
  end
end
