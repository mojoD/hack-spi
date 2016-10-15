#!/usr/bin/env ruby -rubygems
# Sonic Pi Visualizer Server

require 'socket'

def spawnVisualizer
  $sock = UDPSocket.new 
  directoryname = File.dirname(__FILE__)
  filename = "start ruby " + '"' + directoryname + "/extensions/SpiViz.rb" + '"' 
  system(filename)
end

def gl (*args)
  argHash = args[0]
  data = ""
  if argHash.to_s == "quit" 
    data = "quit"
  else
    argHash.each do |key, value| 
      data = data.to_s + "#{key}" + ": " +  "#{value}" + ","    
    end
    data = data.chop
  end
  $sock.send(data, 0, 'localHost', 33333)
end 

def glmidi (*args)
  data = args[0]
  $sock.send(data, 0, 'localHost', 33333)
end 

def glsend(*args)
  data = ""
  args.each do |arg_item|
    data = data + arg_item.to_s
  end 
  $sock.send(data.to_s, 0, 'localHost', 33333)
end

