#!/usr/bin/env ruby
# encoding: utf-8

require 'micromidi'
require 'socket'

$sock = UDPSocket.new 

midinote = ""
input = UniMIDI::Input.gets  
puts "uniMidi: " + input.to_s
puts "name: " + input.name.to_s

MIDI.using(input) do        
  loop do
    m = input.gets
    puts "m: " + m.to_s
    midicmd = m[0][:data][0]
    midinote = m[0][:data][1]     
    midivelocity = m[0][:data][2]
    timestamp = m[0][:timestamp]
    if midivelocity != nil
    #if midicmd == 144 
      if midivelocity > 0
        midiThru = [midinote, midivelocity, timestamp].to_s 
        $sock.send(midiThru, 0, 'localHost', 33555)
      end
    end
  end
end
