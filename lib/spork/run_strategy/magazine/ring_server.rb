# ring_server.rb
require 'rinda/ring'
require 'rinda/tuplespace'

DRb.start_service

Rinda::RingServer.new(Rinda::TupleSpace.new)
puts "Ringer Server listening for connections...\n\n"
$stdout.flush
DRb.thread.join
