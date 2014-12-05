# Conduit

An Event Store for Ruby.

Instead of just storing the current state of an aggregate/entity in a data store we store an event, usually an action performed by a user. This provides a journel of how an aggregate/entity got to its current state.

Projections create read-only denormalized views of your data meaning you can query your data without `JOIN`'s for optimal performance.

In essence reading and writing of data are seperate processes. Events are written and denormalized data is read. 

The read data can, optionally, be constructed asynchronously on a different machine. If so the read data will become eventually consistent.

## Installing

```ruby
gem 'conduit'
```

## Creating a store

```ruby
$store = Conduit::EventStore.new
```

By default an in memory store is used for persistance, in production pass in a symbol, e.g. `:mongo`.

## Pushing events

```ruby
$store.push(:thingy_created, 1, { ... })
```

Events consist of an event name, the id of an aggregate/entity and a hash containing the details of the event. For example the hash might contain the changes to an aggregate/entity.

Note that an id is required even for "create" events, as such the id must be supplied before any data is written to a data store, this negates the use of auto increment id's.

Typically you will push an event from a domain service object, e.g.

```ruby
class RegisterPerson  
  class Form
    include ActiveModel::Model
    include Virtus
    
    attribute :first_name, String
    attribute :last_name,  String
    
    validate :first_name, :last_name, presence: true
  end
  
  def execute(form)
    return false unless form.valid?
        
    id = SecureRandom.uuid    
    $store.put(:person_registered, id, form.attributes)
  end  
end
```

Events are always named in the past tense. It might seem odd to say something is done before it is even persisted to some permanent data store. But from the point of view of a user, as soon as they press a button, to them it is considered done, an action has been completed.

## Reading a stream of events

```ruby
events = $store.get(id)

first_event = events[0]

first_event.id # => ...
first_event.name # => :person_registered
first_event.data # => { first_name: 'Kris', last_name: 'Leech' }
first_event.recorded_at # => ...
```

It is up to you what you store in the `data` hash it might include details about who triggered the event.

An entity can be reconstructed from the events:

```ruby
class Person
  include Virtus
  
  attribute :id,         String
  attribute :first_name, String
  attribute :last_name,  String
end

class ReplyPersonEvents
  def call(events)
    Person.new.tap |person|
      events.each do |event| # TODO: replace with inject/reduce
        person.attributes = data        
      end  
    end
  end  
end
```

In most cases an entity will be made up of different kinds of events, e.g. "person_registered", "person_updated", "person_retired", which all reflect the domain language. If we needed to handle more than just "person_registered" in `ReplyPersonEvents` we could map each event to a different handler class.

## Creating projections

Creating aggregates/entities from an event stream will not be performant when the number of events increases.

To gain performance back we can create snapshots of the current state in a regular data store.

Not only can we create the current state of the entity we can make it totally denormalized and create different denormalized views of the data, meaning no more slow `JOIN` or equivalent queries.

We can subscribe our own objects to the event store and they will be notified when an event occurs.

```ruby
$store.subscribe(PersonProjection.new)

class PersonProjection # TODO: better name, ProjectPerson?
  def on_person_registered(event)
    PersonRepo.__put__(data.merge(uuid: event.id))
  end
end
```

`PersonRepo` can be implimented in any way, to use any data store, for example a relation database could be implimented with `ActiveRecord`:

```ruby
class PersonRepo < ActiveRecord::Base  
  set_table_name :people
  
  # this is only ever called from a projection
  def self.__put__(attributes)
    record = find_by_id(attributes.fetch(:uuid)) || new
    record.update_attributes(attributes)
  end
  
  def self.get(uuid)
    record = find_by_id(uuid)
    Person.new(record.attributes)
  end
end
```

FIXME: implimentation-wise it might be better to fetch the current entity from the repo and then use `ReplyPersonEvents` passing in the single event to get the current state and then save it. Otherwise we have two ways of setting state - reply and SQL.

FIXME: should the repo be inside the projection and instead of "getting" from the repo we "get" from the projection? This would make sense when there are multiple projections as each would need its own repo.

FIXME: or TDD it and see what happens...

Now instead of replaying all the events we can grab the current state directly from a data store, pre-denormalized. 

```ruby
person = PersonRepo.get(uuid)
```

Disk space is cheap, instead of writing an finder method (SQL query) write a new projection passing in the historical events to get it up to date.

Projections can be used to create temporary data views, e.g. for reporting purposes.

### Async 

Subscribed projections can be configured to be called async using Celluloid or Sidekiq.

In a web app this would happen outside the request/response cycle and could be a problem if the new data is displayed stright away in the UI. If stale data is an issue and you still want async, you could recreate what will be eventually created in the data store.

```ruby
# add ability to reply on to an existing object
class ReplyPersonEvents
  def call(events, options: {})
    person = options.fetch(:onto, Person.new)
    person.tap |person|
      Array(events).each do |event| # TODO: replace with inject/reduce
        person.attributes = data        
      end  
    end
  end  
end


event = $store.write(:person_registered, id, form.attributes)

# we reply the single new event on to the existing entity
@person = ReplyPersonEvents.call(event, onto: PersonRepo.fetch(params[:id])
```

# Things to consider

What if the data store (SQL) is down or an error occurs? The snapshot can't be updated and will be stale/invalid. Maybe the store could require an `ack` from the subscriber and redeliver - but then we start to build an event bus, e.g. RabbitMQ. Or we could notify someone and allow them to fix it, events can be replayed from the date of last update to bring back up to date.

```ruby
PersonRepo.each do |record|
  events = $store.read(record.uuid, since: record.updated_at)
  person = ReplayPersonEvents.call(events)
  record.update(person.attributes)
end
```

This could even happen continually in a seperate process, in which case there is no need to subscribe any projections (but it might be better for development/debugging purposes).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/conduit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
