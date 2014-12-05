require 'spec_helper'

describe 'Conduit::Event' do
  describe '#new' do
    it 'initializes from given hash of attributes' do
      event = Conduit::Event.new({ name: 'person_created', aggregate_id: 1, data: { foo: 'bar' } })

      is(event.name)         == 'person_created'
      is(event.aggregate_id) == 1
      is(event.data)         == { foo: 'bar' }
    end
  end
end
