require 'spec_helper'

describe 'Conduit::Store' do
  let(:persistence) { Conduit::Persistence::InMemory.new }
  let(:clock)       { double('Time', now: Time.now) }
  let(:store)       { Conduit::Store.new(persistence, clock) }

  before do
    put_event(aggregate_id: 1)
    put_event(aggregate_id: 1)
    put_event(aggregate_id: 2)
    put_event(aggregate_id: 3)
  end

  describe '#put' do
    it 'persists the events' do
      is(store.get(aggregate_id: 1).size) == 2
      is(store.get(aggregate_id: 2).size) == 1
      is(store.get(aggregate_id: 3).size) == 1
    end

    it 'records the current time' do
      first_event = store.get(aggregate_id: 1).first
      is(first_event.recorded_at) == clock.now
    end

    it 'returns an Event object' do
      expect(store.put(name: 'example', aggregate_id: 1)).is_a?(Conduit::Event)
    end
  end

  describe '#get' do
    it 'retrieves all events for a given aggregate_id' do
      is(store.get(aggregate_id: 1).size) == 2
      is(store.get(aggregate_id: 2).size) == 1
      is(store.get(aggregate_id: 3).size) == 1
    end

    it 'returns an empty collection when aggregate_id has no events' do
      is(store.get(aggregate_id: 999)).empty?
    end

    it 'returns Event objects' do
      is(store.get(aggregate_id: 1).first).is_a?(Conduit::Event)
    end
  end

  describe '#all' do
    it 'returns all events' do
      is(store.all.size) == 4
    end

    it 'returns Event objects' do
      is(store.all.first).is_a?(Conduit::Event)
    end
  end

  it 'is enumerable' do
    # reduce is not included as it returns nil
    %w(each map select reject).each do |method|
      assert(store.public_send(method)).is_a?(Enumerator)
    end
  end

  def put_event(aggregate_id:)
    store.put(name: :person_created,
              aggregate_id: aggregate_id,
              data: { id: 1, first_name: 'Kris' })
  end
end
