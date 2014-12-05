require 'spec_helper'

describe 'Conduit::Store' do
  let(:persistence) { Conduit::Persistence::InMemory.new }
  let(:store)       { Conduit::Store.new(persistence) }

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
  end

  describe '#all' do
    it 'returns all events' do
      is(store.all.size) == 4
    end
  end

  it 'is enumerable' do
    %w(map reduce select reject).each do |method|
      store.respond_to?(method)
    end
  end

  def put_event(aggregate_id:)
    store.put(name: :person_created,
              aggregate_id: aggregate_id,
              data: { id: 1, first_name: 'Kris' })
  end
end
