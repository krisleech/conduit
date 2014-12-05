# TODO

Allow objects to subscribe to events pushed to store

store.subscribe
or
Store.subscribe

broadcasts on_event and on_person_created

listeners can be used to hook in projections etc.

Note: there is no need for async if the event is being published async, unless
two different async mechanisms are being used, e.g. Celluoid for event store
and Sidekiq/RabbitMQ for projections.

----

Add `since` option to #get to filter events by date

----

Allow event store to, optionally, be to called async (Actor) using Celluloid.
Becomes fire and forget.

----

Add error handling for failures in store#put -> allow a block to be called.

----

Add Mongo persistence

----

Add configuration for persistence, e.g. URL, user, pass
