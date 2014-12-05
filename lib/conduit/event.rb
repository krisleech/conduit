require 'anima'

module Conduit
  class Event
    include Anima.new(:name, :aggregate_id, :data, :recorded_at)
  end
end
