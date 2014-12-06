require 'spec_helper'
require 'date'

describe 'Conduit::Store' do
  describe '#get' do
    describe 'since argument' do
      let(:persistence) { Conduit::Persistence::InMemory.new }
      let(:clock)       { double('Clock', now: Time.now) }
      let(:store)       { Conduit::Store.new(persistence, clock) }

      before do
        put_event(aggregate_id: 1, stub_time: days_ago(5))
        put_event(aggregate_id: 1, stub_time: days_ago(5))
        put_event(aggregate_id: 1, stub_time: days_ago(3))
        put_event(aggregate_id: 2, stub_time: days_ago(2))
      end

      it 'returns events after given date' do
        is(store.get(aggregate_id: 1, since: days_ago(2)).size) == 0
        is(store.get(aggregate_id: 1, since: days_ago(4)).size) == 1
        is(store.get(aggregate_id: 1, since: days_ago(6)).size) == 3

        is(store.get(aggregate_id: 2, since: days_ago(1)).size) == 0
        is(store.get(aggregate_id: 2, since: days_ago(3)).size) == 1
      end
    end
  end

  def put_event(aggregate_id:, stub_time: days_ago(0))
    stub(clock, now: stub_time)
    store.put(name: :person_created,
              aggregate_id: aggregate_id,
              data: { id: 1, first_name: 'Kris' })
  end

  def days_ago(days)
    (Date.today - days).to_time
  end
end
