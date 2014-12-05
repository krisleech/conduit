require 'spec_helper'

describe 'Conduit::Persistence::InMemory' do
  let(:persistence) { Conduit::Persistence::InMemory.new }

  describe 'initialization' do
    it 'has no data' do
      is(persistence.count).zero?
    end
  end

  context 'events exist' do
    before do
      put_event(aggregate_id: 1)
      put_event(aggregate_id: 1)
      put_event(aggregate_id: 2)
      put_event(aggregate_id: 3)
    end

    describe '#put' do
      it 'persists events' do
        expect(persistence.count) == 4
      end

      it 'persists multiple events for the same aggregate' do
        expect(persistence.get(aggregate_id: 1).size).to == 2
        expect(persistence.get(aggregate_id: 2).size).to == 1
        expect(persistence.get(aggregate_id: 3).size).to == 1
      end
    end

    describe '#get' do
      it 'returns events for a given aggregate_id' do
        expect(persistence.get(aggregate_id: 1).size).to == 2
        expect(persistence.get(aggregate_id: 2).size).to == 1
        expect(persistence.get(aggregate_id: 3).size).to == 1
      end
    end

    def put_event(aggregate_id:)
      persistence.put(name:         :thing_created,
                      aggregate_id: aggregate_id,
                      data:         { id: 1, name: 'Kris Leech' })
    end
  end
end
