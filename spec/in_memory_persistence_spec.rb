require 'spec_helper'
require 'date'

describe 'Conduit::Persistence::InMemory' do
  let(:persistence) { Conduit::Persistence::InMemory.new }

  describe 'initialization' do
    it 'has no data' do
      is(persistence.count).zero?
    end
  end

  it 'is enumerable' do
    # reduce is not included as it returns nil
    %w(each map select reject).each do |method|
      assert(persistence.public_send(method)).is_a?(Enumerator)
    end
  end

  context 'events exist' do
    before do
      # FIXME: this is confusing
      put_event(aggregate_id: 1, recorded_at: days_ago(5))
      put_event(aggregate_id: 1, recorded_at: days_ago(3))
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

      it 'returns events since given date' do
        expect(persistence.get(aggregate_id: 1, since: days_ago(1)).size).to == 0
        expect(persistence.get(aggregate_id: 1, since: days_ago(4)).size).to == 1
        expect(persistence.get(aggregate_id: 1, since: days_ago(6)).size).to == 2
      end

      it 'returns collection of hashes with all keys' do
        first_event = persistence.get(aggregate_id: 1).first
        expect(first_event).is_a?(Hash)
        %i(name aggregate_id data recorded_at).each do |key|
          expect(first_event).has_key?(key)
        end
      end
    end

    def put_event(aggregate_id:, recorded_at: nil)
      recorded_at ||= Time.now
      persistence.put(name:         :thing_created,
                      aggregate_id: aggregate_id,
                      data:         { id: 1, name: 'Kris Leech' },
                      recorded_at:  recorded_at)
    end

    def days_ago(days)
      (Date.today - days).to_time
    end
  end
end
