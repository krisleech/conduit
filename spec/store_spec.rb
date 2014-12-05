require 'spec_helper'

class Conduit::Store
  def initialize(persistence)
    @persistence = persistence
  end

  def push(name:, aggregate_id:, data: {})
    @persistence.put(name: name, aggregate_id: aggregate_id, data: data)
  end
end

describe 'Conduit::EventStore' do
  describe '#put' do
    it 'persists the event' do

      persistence = InMemoryPersistence.new

      # FIXME: might as well use a double... or make this a real end-to-end
      # test and 'fetch' after the 'push'.
      expect(persistence).to_receive(:put).with({name:         :thing_created,
                                                 aggregate_id: 1,
                                                 data:         { id: 1, first_name: 'Kris' }})

      store = Conduit::Store.new(persistence)

      store.push(name: :thing_created,
                  aggregate_id: 1,
                  data: { id: 1, first_name: 'Kris' })
    end
  end
end
