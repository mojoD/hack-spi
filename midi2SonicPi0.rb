
#! /usr/bin/env ruby 
# 
# usage: midi2SonicPi6.rb [midi_file_in] [output_directory] 
# 
# This program reads in a midi file and creates a midiloop file (extension .mloop) for each track in the midifile
# It sits on top of the midilib ruby code written by Jim Menard @ https://github.com/jimm/midilib
# The midiloop files are intended to be consumed by Sonic Pi using the midiplayer ruby code I wrote.
# This program builds separate Midiloop files for each instrument (i.e. piano, guitar, bass, strings, etc) and for drums one mloop file for each drum in the drum kit.
 
# Start looking for MIDI module classes in the directory above this one. 
# This forces us to use the local copy, even if there is a previously 
# installed version out there somewhere. 
$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib') 
  
# The Midilib modules are installed at Ruby23 > lib > ruby > gems > 2.3.0 > midilib-2.0.5 > lib 
require 'midilib/sequence' 
require 'midilib/consts'
require 'FileUtils'
include MIDI

# Read from MIDI file 
seq = MIDI::Sequence.new() 

# Make directory for header, logfile and mloop files created by this program
directoryname = ARGV[1]
FileUtils.rm_rf(directoryname)
Dir.mkdir(directoryname) unless File.exists?(directoryname)
 
File.open(ARGV[0], 'rb') do |file| #rb means read, binary and not ruby in parms
  # The block we pass in to Sequence.read is called at the end of every 
  # track read. It is optional, but is useful for progress reports. 
  seq.read(file) do |track, num_tracks, i| 
    #outfile.puts "read track #{track ? track.name : ''} (#{i} of #{num_tracks})" 
  end 
end 

# Midi Arrays
MidiArray = [] 
ChannelArray = []
TimeFromStartArray = []
StatusArray = []
NoteArray = []
VelocityArray = []
ProgramChangeArray = []
ProgramChannelArray = []
ProgramTimeFromStartArray = []
ProgramNameArray = []
ControllerVolumeArray = []
SequencerArray = []
mLoopArray = []

def FindNoteOff (currentArrayPos, currentNote)
  for i in currentArrayPos..ChannelArray.length  
	  if NoteArray[i] == currentNote && StatusArray[i] == "128" 	
      duration = TimeFromStartArray[i].to_f - TimeFromStartArray[currentArrayPos].to_f
	    return duration.to_i
	    break
	  end
  end
end 

# Create Header and Log files
headerfilename = directoryname + "/header.txt"
logfilename = directoryname + "/logfile.txt"
logfile = File.new(logfilename, "w+")
headerfile = File.new(headerfilename, "w+")

# This executes for every track
# Builds the Note, Controller and Program (Instruments) Arrays
trackcntr = -1
seq.each do |track|
  trackcntr += 1
  track.each do |e|
 
    e.print_decimal_numbers = true # default = false (print hex) 
    e.print_note_names = false # default = false (print note numbers)
    e.print_channel_numbers_from_one = false  # starts with channel 1 instead of channel 0 midi Channels in the data start with 0 to 15 that means that drums show up as channel 9
    logfile.puts e
    
    # Pull Sequence Header info (i.e. Meta Events)
    if e.kind_of?(MIDI::TimeSig)
      headerfile.puts e.to_s
    end
    if e.kind_of?(MIDI::Tempo)
      headerfile.puts "BPM: " + Tempo.mpq_to_bpm(e.tempo).to_i.to_s
    end
    if e.kind_of?(MIDI::Tempo)
      headerfile.puts "Tempo: " + e.tempo.to_s
    end
    if e.kind_of?(MIDI::KeySig)
      key = " "
      scale = " "
      puts "KeySig: " + e.to_s
      case e.to_s
      when "key sig C flat major"
        key = ":cb3"
        scale = ":major"
      when "key sig G flat major"
        key = ":gb3"
        scale = ":major"
      when "key sig D flat major"
        key = ":db3"
        scale = ":major"
      when "key sig A flat major"
        key = ":ab3"
        scale = ":major"
      when "key sig E flat major"
        key = ":eb3"
        scale = ":major"                        
      when "key sig B flat major"
        key = ":bb3"
        scale = ":major"
      when "key sig F major"
        key = ":f3"
        scale = ":major"
      when "key sig C major"
        key = ":c3"
        scale = ":major"
      when "key sig G major"
        key = ":g3"
        scale = ":major"
      when "key sig D major"
        key = ":d3"
        scale = ":major"  
      when "key sig A major"
        key = ":a3"
        scale = ":major"
      when "key sig E major"
        key = ":e3"
        scale = ":major"
      when "key sig B major"
        key = ":b3"
        scale = ":major"
      when "key sig F# major"
        key = ":gb3"
        scale = ":major"
      when "key sig C# major"
        key = ":db3"
        scale = ":major"       
      when "key sig a flat minor"
        key = ":ab3"
        scale = ":minor"
      when "key sig e flat minor"
        key = ":eb3"
        scale = ":minor"  
      when "key sig b flat minor"
        key = ":bb3"
        scale = ":minor"  
      when "key sig f minor"
        key = ":f3"
        scale = ":minor"    
      when "key sig c minor"
        key = ":c3"
        scale = ":minor"
      when "key sig g minor"
        key = ":g3"
        scale = ":minor"  
      when "key sig d minor"
        key = ":d3"
        scale = ":minor"  
      when "key sig a minor"
        key = ":a3"
        scale = ":minor"   
      when "key sig e minor"
        key = ":e3"
        scale = ":minor"
      when "key sig b minor"
        key = ":b3"
        scale = ":minor"  
      when "key sig f# minor"
        key = ":gb3"
        scale = ":minor"  
      when "key sig c# minor"
        key = ":db3"
        scale = ":minor"    
      when "key sig g# minor"
        key = ":ab3"
        scale = ":minor"
      when "key sig d# minor"
        key = ":eb3"
        scale = ":minor"  
      when "key sig a# minor"
        key = ":bb3"
        scale = ":minor"
        end
      headerfile.puts "key: " + key.to_s
      headerfile.puts "scale: " + scale.to_s
    end

    # Create Arrays which will be used to create MLOOP Files
    if e.kind_of?(MIDI::NoteEvent)
        # Midi Notes
	     ChannelArray.push(e.channel.to_s)
	     TimeFromStartArray.push(e.time_from_start.to_s)
	     StatusArray.push(e.status.to_s)
	     NoteArray.push(e.note.to_s)
        VelocityArray.push(e.velocity.to_s)
     elsif e.status == CONTROLLER
        if CONTROLLER_NAMES[e.controller] == "Volume"
          ControllerVolumeArray.push(e.channel.to_s + "," + e.time_from_start.to_s + "," + CONTROLLER_NAMES[e.controller].to_s + "," + e.value.to_s)
        end
      elsif e.status == PROGRAM_CHANGE
        ProgramChangeArray.push(e.program)
        ProgramChannelArray.push(e.channel)
        ProgramTimeFromStartArray.push(e.time_from_start)
        ProgramNameArray.push(GM_PATCH_NAMES[e.program])
    end
  end
  
  # Build the MLOOP Output files for the Track if the track has notes in it
  if NoteArray.length != 0
    trackfilename = track.name.chop #delete end of string \r\n bytes 
    trackfilename = trackfilename.gsub(">"," ") #deletes illegal characters
    trackfilename = trackfilename.gsub("<"," ") #deletes illegal characters

    if ProgramNameArray.length != 0  #Drum tracks do not have a program change for instruments as each note is a different drum in the kit.
      instrumentname = ProgramNameArray[0].to_s 
    end

    if trackcntr < 10
      strtrackcntr = "0" + trackcntr.to_s
    else
      strtrackcntr = trackcntr.to_s
    end
    if strtrackcntr.to_s == "10" 
      instrumentname = "Drum Kit"
    end
    filename = directoryname.to_s + "/" + "Track" + "_" + strtrackcntr + " - " + trackfilename.to_s + " - " + instrumentname.to_s + ".mloop"
    mLoopArray.push(filename)
    puts filename
    outfile = File.new(filename,"w+")

    outfile.puts "*** track name \"#{track.name}\"" 
    outfile.puts "instrument name \"#{track.instrument}\"" 
    outfile.puts "#{track.events.length} events"
  
    currentArrayPos = 0
    currentChannel = ChannelArray[0]
    currentNote = NoteArray[0]
    currentStatus = StatusArray[0]

    # Output Program Change Information by Channel
    outfile.puts "Instrument Changes"
    if ProgramNameArray.length != 0
      for i in 0..ProgramTimeFromStartArray.length-1
        outfile.puts ProgramChannelArray[currentArrayPos].to_s + "," + ProgramTimeFromStartArray[currentArrayPos].to_s + "," + ProgramChangeArray[currentArrayPos].to_s + "," + ProgramNameArray[currentArrayPos].to_s
        currentArrayPos += 1
      end
    end

    # Output Controller Changes
    currentArrayPos = 0
    initialVolume = 0
    outfile.puts "Controller Changes"
    if ControllerVolumeArray.length != 0
      for i in 0..ControllerVolumeArray.length-1
        outfile.puts ControllerVolumeArray[currentArrayPos]
        if currentArrayPos == 0 
          initialVolume = ControllerVolumeArray[currentArrayPos].split(",")[3].to_s
        end
        currentArrayPos += 1
      end
    end

    # Build current sequencer record for track being read
    initialVolumeFloat = (initialVolume.to_f / 64.0).to_f
    initialVolumeFloat = initialVolumeFloat.round(1)
    if trackcntr.to_s != "10"
      sequencerRecord = trackcntr.to_s + "," + '"sample"' + "," + "0" + "," + ProgramChangeArray[0].to_s + ',"' + ProgramNameArray[0].to_s + '",' +  initialVolumeFloat.to_s + ","  + '"play"' + "," + '"mono"' + "," + '"novelocity"' + "," + '"NoEffects"'
    else
      sequencerRecord = trackcntr.to_s + "," + '"sample"' + "," + "128" + "," + "0" + "," + '"Drum Kit"' + "," +  initialVolumeFloat.to_s + ","  + '"play"' + "," + '"mono"' + "," + '"novelocity"' + "," + '"NoEffects"' # drum kit record, assume bank 128, program 0 drum kit being used      
    end
    SequencerArray.push(sequencerRecord.to_s)

    # Output Note Events with Durations
    currentArrayPos = 0
    prevTimeFromStart = 0
    outfile.puts "Notes"
    for i in 0..ChannelArray.length
      if currentStatus == "144" then
        durationcalc = FindNoteOff currentArrayPos, currentNote
        if currentArrayPos != 0 then
          deltatime = TimeFromStartArray[currentArrayPos].to_i - prevTimeFromStart.to_i
        else
          deltatime = TimeFromStartArray[0]
        end
        outfile.puts ChannelArray[currentArrayPos] + "," +\
          TimeFromStartArray[currentArrayPos] + "," +\
          deltatime.to_s  + "," +\
          StatusArray[currentArrayPos] + "," + \
          durationcalc.to_s + "," +\
          NoteArray[currentArrayPos] + "," +\
          VelocityArray[currentArrayPos]
        prevTimeFromStart = TimeFromStartArray[currentArrayPos]   
      end

      currentArrayPos += 1
      currentChannel = ChannelArray[currentArrayPos]
      currentNote = NoteArray[currentArrayPos]
      currentStatus = StatusArray[currentArrayPos]    
    end
    
    #Track Loop Cleanup
    outfile.close
    ChannelArray.clear
    TimeFromStartArray.clear
    StatusArray.clear
    NoteArray.clear
    VelocityArray.clear
    ProgramChannelArray.clear
    ProgramTimeFromStartArray.clear
    ProgramChangeArray.clear
    ProgramNameArray.clear
    ControllerVolumeArray.clear
  end
end

# Write Ruby Code Out records out for Sequencer

curDir = Dir.getwd
defaultSoundFontDir = curDir + "/default/"
#puts "SoundFonts: " + defaultSoundFontDir.to_s
mLoopDir = curDir + "/" + directoryname + "/"
#puts "mLoopDir: " + mLoopDir.to_s

sequencerfilename = directoryname + "/sequencer.rb"
sequencerfile = File.new(sequencerfilename, "w+")
looperfilename = directoryname + "/looper.rb"
looperfile = File.new(looperfilename, "w+")
currentArrayPos = 0
#puts "sequencer array length: " + SequencerArray.length.to_s
if SequencerArray.length != 0
   sequencerfile.puts "mMixer = [\\"
   looperfile.puts "mMixer = [\\"   
   for i in 0..SequencerArray.length-1
      if i == SequencerArray.length-1
        sequencerfile.puts SequencerArray[currentArrayPos].to_s + "\\"
        looperfile.puts SequencerArray[currentArrayPos].to_s + "\\"        
      else
        sequencerfile.puts SequencerArray[currentArrayPos].to_s + ",\\"
        looperfile.puts SequencerArray[currentArrayPos].to_s + ",\\"        
      end
      currentArrayPos += 1
    end
    sequencerfile.puts "]"
    looperfile.puts "]"    
end

# Write Out Ruby Code Template for Songs
sequencerfile.puts " "
sequencerfile.puts "#Define Arrays and Variables used"
sequencerfile.puts 'midiBuildType = "sequencer"'
sequencerfile.puts "mNoteArray = []"
sequencerfile.puts "mLoopIndex = 0"
sequencerfile.puts "mProgramArray = []"
sequencerfile.puts "sMixerPresetArray = []"
sequencerfile.puts " "
sequencerfile.puts 'gMPathDir = "' + defaultSoundFontDir + '" # Use Directory Generated by sf2SonicPi.rb'
sequencerfile.puts "sMixerPresetArray = buildGMSampleArray(gMPathDir, mMixer)"
sequencerfile.puts " "
sequencerfile.puts 'mLoopDir = "' + mLoopDir + '" #use Directory Generated by midi2SonicPi.rb'
sequencerfile.puts " "
sequencerfile.puts "setBPM = getBPM mLoopDir"
sequencerfile.puts "bpm = setBPM.to_i # read in from file  override it with manual number i.e. 120 if you dont want to use Midifile BPM"
sequencerfile.puts 'puts "use_bpm " + bpm.to_s'
sequencerfile.puts "use_bpm bpm * 1.7  #clock runs slower in Sonic Pi than Midi tempo" 
sequencerfile.puts " "
sequencerfile.puts "keyIn = getkeyIn mLoopDir"
sequencerfile.puts 'puts "keyIn: " + keyIn.to_s'
sequencerfile.puts " "
sequencerfile.puts "scaleIn = getscaleIn mLoopDir"
sequencerfile.puts 'puts "scaleIn: " + scaleIn.to_s'
sequencerfile.puts " "
sequencerfile.puts 'buildMidiArrays gMPathDir, mLoopDir, midiBuildType, sMixerPresetArray, mMixer'

sequencerfile.close

# Build Looper Version Ruby Code Template
looperfile.puts " "
looperfile.puts "#Define Arrays and Variables used"
looperfile.puts 'midiBuildType = "looper"'
looperfile.puts "mNoteArray = []"
looperfile.puts "mLoopIndex = 0"
looperfile.puts "mProgramArray = []"
looperfile.puts "sMixerPresetArray = []"
looperfile.puts " "
looperfile.puts 'gMPathDir = "' + defaultSoundFontDir + '" # Use Directory Generated by sf2SonicPi.rb'
looperfile.puts "sMixerPresetArray = buildGMSampleArray(gMPathDir, mMixer)"
looperfile.puts " "
looperfile.puts 'mLoopDir = "' + mLoopDir + '" #use Directory Generated by midi2SonicPi.rb'
looperfile.puts " "
looperfile.puts "setBPM = getBPM mLoopDir"
looperfile.puts "bpm = setBPM.to_i # read in from file  override it with manual number i.e. 120 if you dont want to use Midifile BPM"
looperfile.puts 'puts "use_bpm " + bpm.to_s'
looperfile.puts "use_bpm bpm * 1.7  #clock runs slower in Sonic Pi than Midi tempo" 
looperfile.puts " "
looperfile.puts "keyIn = getkeyIn mLoopDir"
looperfile.puts 'puts "keyIn: " + keyIn.to_s'
looperfile.puts " "
looperfile.puts "scaleIn = getscaleIn mLoopDir"
looperfile.puts 'puts "scaleIn: " + scaleIn.to_s'
looperfile.puts " "

# MidiLoops for all Tracls 

numoftimes = mLoopArray.length.to_i
numoftimes.times do |i|

  looperfile.puts 'mloops = "' + mLoopArray[i].to_s.split("/")[1] + '"'
  looperfile.puts "midiArray" + i.to_s + " = readMidiLoop(mLoopDir, mloops)"  
  looperfile.puts "sampleFileName" + i.to_s + ' = gMPathDir + ' + 'sMixerPresetArray[' + i.to_s + '].split(",")[10]' + ' + ".pisf"'
  looperfile.puts "sampleArray" + i.to_s + " = getSample(sampleFileName" + i.to_s + ", gMPathDir)"
  looperfile.puts "live_loop :sampleloop_Channel" + i.to_s + " do"
  looperfile.puts "  numofnotes" + i.to_s + " = midiArray" + i.to_s + ".length"
  looperfile.puts "  numofnotes" + i.to_s + ".times do |i|"
  looperfile.puts "    msleep" + i.to_s + " = midiArray" + i.to_s + '[i].split(",")[2].to_i/120.to_f.round(2)'
  looperfile.puts "    sampleRec" + i.to_s + " = sampleArray" + i.to_s + "[midiArray" + i.to_s + '[i].split(",")[5].to_i].to_s'
  looperfile.puts "    sampleToPlay" + i.to_s + " = gMPathDir.to_s + sampleRec" + i.to_s + '.split(",")[3].to_s' + ' + ".wav"'
  looperfile.puts "    rateToPlay" + i.to_s + " = sampleRec" + i.to_s + '.split(",")[2]'
  looperfile.puts "    noteRelease" + i.to_s + " = midiArray" + i.to_s + '[i].split(",")[4].to_i/120.to_f'
  looperfile.puts "    sample sampleToPlay" + i.to_s + ", rate: rateToPlay" + i.to_s + ", release: noteRelease" + i.to_s + ", amp: " + SequencerArray[i].split(",")[5]
  looperfile.puts "    sleep msleep" + i.to_s 
  looperfile.puts "  end"
  looperfile.puts "end"
  looperfile.puts " "
end

looperfile.close
# Write Sequencer records out
#drumkitfilename = directoryname + "/drumkit.txt"
#drumkitfile = File.new(drumkitfilename, "w+")
#currentArrayPos = 0
#puts "drumkit array length: " + drumKit.length.to_s
#if drumKit.length != 0
#   drumkitfile.puts "mDrumKit = [\\"
#   for i in 0..drumKit.length-1
      #puts SequencerArray[currentArrayPos]
#      drumkitfile.puts drumKit[currentArrayPos].to_s + ",\\"
#      currentArrayPos += 1
#    end
#    drumkitfile.puts "]"
#  drumkitfile.close
#end

logfile.close
headerfile.close
