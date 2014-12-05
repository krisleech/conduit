require 'anima'

module Conduit
  class Event
    include Anima.new(:name, :aggregate_id, :data)
  end
end
