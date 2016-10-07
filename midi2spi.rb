
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
  
# The Midilib modules are installed at Ruby23 > lib > ruby > gems > 2.3.0 > gems > midilib-2.0.5 > lib 
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
ProgramChangeHistoryArray = []
ProgramChannelHistoryArray = []
ProgramTimeFromStartHistoryArray = []
ProgramNameHistoryArray = []
ControllerVolumeArray = []
ControllerReverbArray = []
ControllerChorusArray = []
ControllerPanArray = []
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

def SetDefaultReleaseTimes (patchIn)
    patch2ReleaseTimeArray = [0,1.0,1,1.0,2,0.4,3,1.0,4,0.5,5,1.0,6,0.8,7,0.6,8,4.0,9,6.0,\
                            10,3.0,11,0.0,12,3.0,13,2.0,14,3.0,15,0.6,16,0.6,17,0.6,18,0.5,19,3.0,\
                            20,0.7,21,0.5,22,0.2,23,0.5,24,0.7,25,0.3,26,0.5,27,0.5,28,0.4,29,0.2,\
                            30,0.25,31,0.4,32,0.5,33,0.216,34,0.4,35,0.5,36,0.3,37,0.5,38,1.0,39,0.5,\
                            40,0.4,41,0.4,42,0.4,43,0.5,44,1.0,45,2.0,46,3.0,47,12.0,48,1.0,49,1.0,\
                            50,1.0,51,1.0,52,1.0,53,0.3,54,2.0,55,0.0,56,0.3,57,0.3,58,0.3,59,0.4,\
                            60,0.3,61,0.5,62,1.0,63,1.0,64,0.3,65,0.3,66,0.2,67,0.3,68,0.3,69,0.4,\
                            70,0.5,71,0.3,72,0.5,73,0.5,74,0.3,75,0.5,76,0.0,77,0.5,78,0.5,79,0.4,\
                            80,0.5,81,0.5,82,0.4,83,0.3,84,0.3,85,2.0,86,0.5,87,0.3,88,3.0,89,3.0,\
                            90,0.8,91,4.0,92,4.0,93,3.0,94,3.0,95,3.0,96,3.0,97,3.0,98,4.0,99,3.0,\
                            100,4.0,101,4.0,102,4.0,103,4.0,104,2.0,105,0.4,106,0.5,107,0.4,108,1.0,109,0.5,\
                            110,0.3,111,0.4,112,2.0,113,1.0,114,1.2,115,2.0,116,0.0,117,0.0,118,0.0,119,9.998,\
                            120,0.3,121,4.999,122,8.0,123,1.0,124,0.5,125,2.0,126,4.999,127,4.999]
    releaseTime = patch2ReleaseTimeArray[patchIn*2+1]
    return releaseTime  

end

# Create Header and Log files
headerfilename = directoryname + "/header.txt"
logfilename = directoryname + "/logfile.txt"
dumpfilename = directoryname + "/MidiEventDump.txt"
logfile = File.new(logfilename, "w+")
headerfile = File.new(headerfilename, "w+")
dumpfile = File.new(dumpfilename, "w+")

# This executes for every track
# Builds the Note, Controller and Program (Instruments) Arrays
trackcntr = -1
programName = " "
seq.each do |track|
  trackcntr += 1
  track.each do |e|
 
    e.print_decimal_numbers = true # default = false (print hex) 
    e.print_note_names = false # default = false (print note numbers)
    e.print_channel_numbers_from_one = false  # starts with channel 1 instead of channel 0 midi Channels in the data start with 0 to 15 that means that drums show up as channel 9
    dumpfile.puts e
    
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
        if CONTROLLER_NAMES[e.controller] == "External Effects Depth" #Reverb
          ControllerReverbArray.push(e.channel.to_s + "," + e.time_from_start.to_s + "," + CONTROLLER_NAMES[e.controller].to_s + "," + e.value.to_s)
        end 
        if CONTROLLER_NAMES[e.controller] == "Chorus Depth" #Chorus
          ControllerChorusArray.push(e.channel.to_s + "," + e.time_from_start.to_s + "," + CONTROLLER_NAMES[e.controller].to_s + "," + e.value.to_s)
        end           
        if CONTROLLER_NAMES[e.controller] == "Pan" #Pan
          ControllerPanArray.push(e.channel.to_s + "," + e.time_from_start.to_s + "," + CONTROLLER_NAMES[e.controller].to_s + "," + e.value.to_s)
        end      
      elsif e.status == PROGRAM_CHANGE
        ProgramChangeArray.push(e.program)
        ProgramChannelArray.push(e.channel)
        ProgramTimeFromStartArray.push(e.time_from_start)
        ProgramNameArray.push(GM_PATCH_NAMES[e.program])
        ProgramChangeHistoryArray.push(e.program)
        ProgramChannelHistoryArray.push(e.channel)
        ProgramTimeFromStartHistoryArray.push(e.time_from_start)
        ProgramNameHistoryArray.push(GM_PATCH_NAMES[e.program])
    end
  end
  
  #logfile.puts "ProgramChannelArray: " + ProgramChannelArray.to_s
  #logfile.puts "ProgramTimeFromStartArray: " + ProgramTimeFromStartArray.to_s
  #logfile.puts "ProgramChangeArray: " + ProgramChangeArray.to_s
  #logfile.puts "ProgramNameArray: " + ProgramNameArray.to_s

  # Build the MLOOP Output files for the Track if the track has notes in it
  if NoteArray.length != 0
    trackfilename = track.name.chop #delete end of string \r\n bytes 
    trackfilename = trackfilename.gsub(">"," ") #deletes illegal characters
    trackfilename = trackfilename.gsub("<"," ") #deletes illegal characters

    if ProgramNameArray.length != 0  #Drum tracks do not have a program change for instruments as each note is a different drum in the kit.
      instrumentname = ProgramNameArray[0].to_s 
    end

    if trackcntr.to_i < 10 
      strtrackcntr = "0" + trackcntr.to_s
    else
      strtrackcntr = trackcntr.to_s
    end
    if ChannelArray[trackcntr].to_s == "9" 
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
    if ChannelArray[0].to_s == "9" #Build a drum record
      outfile.puts "9,0,128,000,PopDrums" # output a channel 9, time from start of 0, bank 128, program 0, Program Name PopDrums record to midiloop file
    else
      if ProgramNameArray.length != 0
        for i in 0..ProgramTimeFromStartArray.length-1 # assume it is not drums and set the bank to 000
          patchToFindStr = ProgramChangeArray[currentArrayPos].to_s
          patchToFind = ProgramChangeArray[currentArrayPos].to_i
          if patchToFind.to_i < 10
            patchToFindStr = "00" + patchToFind.to_i.to_s
          elsif patchToFind.to_i < 100
            patchToFindStr = "0" + patchToFind.to_i.to_s
          end
          programName = ProgramNameArray[currentArrayPos].to_s
          programName = programName[0..25].rjust(25, " ")

          outfile.puts ProgramChannelArray[currentArrayPos].to_s + "," + ProgramTimeFromStartArray[currentArrayPos].to_s + ",000," + patchToFindStr.to_s + "," + programName.to_s
          currentArrayPos += 1
        end
      else
        #Find if this channel has a previous program change record in the history arrays and if it does use it (often in midi, if a second track is using the same channel as a previous track the second track will not have a program change in it)
        programHistoryCntr = 0
        ProgramChannelHistoryArray.each do |programChannelHistory|
          if programChannelHistory.to_s == ChannelArray[0].to_s
            patchToFindStr = ProgramChangeHistoryArray[currentArrayPos].to_s
            patchToFind = ProgramChangeHistoryArray[currentArrayPos].to_i
            if patchToFind.to_i < 10
              patchToFindStr = "00" + patchToFind.to_i.to_s
            elsif patchToFind.to_i < 100
              patchToFindStr = "0" + patchToFind.to_i.to_s
            end
            programName = ProgramNameHistoryArray[programHistoryCntr]
            outfile.puts ProgramChannelHistoryArray[programHistoryCntr].to_s + "," + ProgramTimeFromStartHistoryArray[programHistoryCntr].to_s + ",000," + patchToFindStr.to_s + "," + programName.to_s          
          end
          programHistoryCntr += 1
        end
      end
    end

    # Output Controller Changes
    currentArrayPos = 0
    initialVolume = 0
    initialReverb = 0
    initialChorus = 0
    initialPan = 64
    initialVibrato = 0
    initialFreqCutoff = 128
    initialTranspose = 0
    initialSliceBegin = 0
    initialSliceEnd = -1
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
    if ControllerReverbArray.length != 0
        outfile.puts ControllerReverbArray[currentArrayPos]
        initialReverb = ControllerReverbArray.last.split(",")[3].to_s
    end     
    if ControllerChorusArray.length != 0
      outfile.puts ControllerChorusArray.last
      initialChorus = ControllerChorusArray.last.split(",")[3].to_s
    end   
    if ControllerPanArray.length != 0
      outfile.puts ControllerPanArray.last
      initialPan = ControllerPanArray.last.split(",")[3].to_s
    end

    # Build current sequencer record for track being read
    initialVolumeFloat = (initialVolume.to_f / 64.0).to_f
    initialVolumeFloat = initialVolumeFloat.round(1)
    initialReverbFloat = (initialReverb.to_f) / 127.0.to_f
    initialReverbFloat = initialReverbFloat.round(1)
    initialChorusFloat = (initialChorus.to_f).to_f
    initialChorusFloat = initialChorusFloat.round(1)
    initialVibratoFloat = (initialVibrato.to_f).to_f
    initialVibratoFloat = initialVibratoFloat.round(1)
    initialFreqCutoffFloat = (initialFreqCutoff.to_f).to_f
    initialFreqCutoffFloat = initialFreqCutoffFloat.round(1)
    initialTransposeInt = initialTranspose.to_i
    initialSliceBeginInt = initialSliceBegin.to_i
    initialSliceEndInt = initialSliceEnd.to_i                  
    initialPanFloat = (((initialPan.to_f) / 64) - 1).to_f
    initialPanFloat = initialPanFloat.round(1)        
    #logfile.puts "trackntr: " + trackcntr.to_s
    #logfile.puts "ChannelArray miditrack: " + ChannelArray[trackcntr-1].to_s
    #logfile.puts "for Program: " + ProgramNameArray[trackcntr-1].to_s
    patchToFindStr = ProgramChangeArray[0].to_s
    patchToFind = ProgramChangeArray[0].to_i
    if patchToFind.to_i < 10
      patchToFindStr = "00" + patchToFind.to_i.to_s
    elsif patchToFind.to_i < 100
      patchToFindStr = "0" + patchToFind.to_i.to_s
    end
    if ChannelArray[trackcntr-1].to_s != "9" 
      releaseTime = SetDefaultReleaseTimes(patchToFind)
      #puts "pathToFind: " + patchToFind.to_s
      #puts "releaseTime: " + releaseTime.to_s
      sequencerRecord = trackcntr.to_s + ", " + '"sample"' + ", " + '"000"' + ', "' + patchToFindStr.to_s + '", "' + programName.to_s + '", ' +  initialVolumeFloat.to_s + ", "  + '"play"' + ",    " + releaseTime.to_s + ", " + initialReverbFloat.to_s + ", " + initialChorusFloat.to_s + ",  " + initialVibratoFloat.to_s + ", " + initialFreqCutoffFloat.to_s + ",  " + initialTransposeInt.to_s + ",   " + initialSliceBeginInt.to_s + ",   " + initialSliceEndInt.to_s + ",   " + initialPanFloat.to_s
    else
      sequencerRecord = trackcntr.to_s + ", " + '"sample"' + ", " + '"128"' + ", " + '"000"' + ", " + '"                 Drum Kit"' + ", " +  initialVolumeFloat.to_s + ", "  + '"play"' + ",    " + '0.0' + ", " + initialReverbFloat.to_s + ", " + initialChorusFloat.to_s + ",  " + initialVibratoFloat.to_s + ", " + initialFreqCutoffFloat.to_s + ",  " + initialTransposeInt.to_s + ",   " + initialSliceBeginInt.to_s + ",   " + initialSliceEndInt.to_s + ",   " + initialPanFloat.to_s # drum kit record, assume bank 128, program 0 drum kit being used      
    end
    SequencerArray.push(sequencerRecord.to_s)

    # Output Note Events with Durations
    currentArrayPos = 0
    prevTimeFromStart = 0
    outfile.puts "Notes"
    # Write out first record to sync timing between tracks because all tracks do not start at the same time and this ensures that the tracks all start at tick 0
    outfile.puts ChannelArray[currentArrayPos] + "," +\
          "0" + "," +\
          "0"  + "," +\
          "144" + "," + \
          "1" + "," +\
          "-1" + "," +\
          "1"

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

testDir = curDir + "/testsf1/"
presetFile = testDir + ".presets.info"
f = File.open(presetFile,'r')
presetInArray = f.readlines
f.close

paramsFile = testDir + ".params.info"
f = File.open(paramsFile,'r') 
paramsInArray = f.readlines
f.close

paramsArray = []
presetInArray.each do |presetRec|
  #puts "presetRec: " + presetRec.to_s
  bank = presetRec.split(",")[0]
  patch = presetRec.split(",")[1]
  instrument = presetRec.split(",")[2]
  #puts "instrument: " + instrument.to_s
  paramsInArray.each do |paramsRec|
    #puts "paramsRec: " + paramsRec.to_s
    instrument2 = paramsRec.split(",")[0]
    sustain = paramsRec.split(",")[1]
    decay = paramsRec.split(",")[2]
    release = paramsRec.split(",")[3]
    reverb = paramsRec.split(",")[4]
    chorus = paramsRec.split(",").last
    #puts "instrument2: " + instrument2.to_s
    if instrument.to_s == instrument2.to_s
      #puts "found instrument in params "
      paramsArrayRec = bank.to_s + "," + patch.to_s + "," + sustain.to_s + "," + decay.to_s + "," + release.to_s + "," + reverb.to_s + "," + chorus.to_s
      #puts "paramsArrayRec: " + paramsArrayRec.to_s 
      paramsArray.push paramsArrayRec
    end
  end
end

mLoopDir = curDir + "/" + directoryname + "/"
synthdefDir = curDir + "/my-synths/" 
#puts "mLoopDir: " + mLoopDir.to_s
#sequencerfile.puts "#Mixer: Track, Sample/Synth, Bank, Patch, Name, Amp, play/mute, releaseTime, Reverb, Chorus, Vibrato, Freq Cuttoff, Transpose, Slice Beg, Slice End, Pan"
currentArrayPos = 0

#puts "sequencer array length: " + SequencerArray.length.to_s
# Write Out Ruby Code Template for Songs


# MidiLoops for all Tracks 
sequencerfilename = directoryname + "/AllTracks.rb"
sequencerfile = File.new(sequencerfilename, "w+")

sequencerfile.puts 'gmPathDir = "' + defaultSoundFontDir + '" # Use Directory Generated by sf2SonicPi.rb'
sequencerfile.puts 'mloopDir = "' + mLoopDir + '" #use Directory Generated by midi2SonicPi.rb' 
sequencerfile.puts 'load_synthdefs "' + synthdefDir + '"'   #C:/Users/Michael Sutton/MidiloopV1/my-synths/
sequencerfile.puts "bpm = getBPM(mloopDir).to_i * 1.0 # read in from file. You will probably have to adjust the multiplier of 1.0 up or down to get the right tempo"  
sequencerfile.puts "use_bpm bpm  "
sequencerfile.puts "set_volume! 1.0"  
sequencerfile.puts " "  

numoftimes = mLoopArray.length.to_i
numoftimes.times do |i|
  rubyfile = mLoopArray[i].to_s.split("/")[1]
  rubyfile = rubyfile.to_s.split(".")[0]
  #puts rubyfile.to_s
  looperfilename = directoryname + "/" + rubyfile + ".rb"
  looperfile = File.new(looperfilename, "w+")

  looperfile.puts 'gmPathDir = "' + defaultSoundFontDir + '" # Use Directory Generated by sf2SonicPi.rb'
  looperfile.puts 'mloopDir = "' + mLoopDir + '" #use Directory Generated by midi2SonicPi.rb'     
  looperfile.puts 'load_synthdefs "' + synthdefDir + '"' 
  looperfile.puts "bpm = getBPM(mloopDir).to_i * 1.0 # read in from file. You will probably have to adjust the multiplier of 1.0 up or down to get the right tempo"
  looperfile.puts "use_bpm bpm  "
  looperfile.puts "set_volume! 1.0"
  looperfile.puts ""
  looperfile.puts "mloops" + i.to_s + ' = "' + mLoopArray[i].to_s.split("/")[1] + '"'
  sequencerfile.puts "mloops" + i.to_s + ' = "' + mLoopArray[i].to_s.split("/")[1] + '"'
  looperfile.puts "      midiIn" + i.to_s + " = readMidiLoop(mloopDir: mloopDir, mloop: mloops" + i.to_s +  ", sliceBegin: '0' , sliceLength: '-1', transpose: 0)"  
  sequencerfile.puts "      midiIn" + i.to_s + " = readMidiLoop(mloopDir: mloopDir, mloop: mloops" + i.to_s +  ", sliceBegin: '0', sliceLength: '-1', transpose: 0)"    
  looperfile.puts "noteArray" + i.to_s +  " = buildMidiNotes(midiIn" + i.to_s + "); timingArray" + i.to_s + " = buildMidiTiming(midiIn" + i.to_s + "); releaseArray" + i.to_s + " = buildMidiRelease(midiIn" + i.to_s + ")"
  sequencerfile.puts "noteArray" + i.to_s +  " = buildMidiNotes(midiIn" + i.to_s + "); timingArray" + i.to_s + " = buildMidiTiming(midiIn" + i.to_s + "); releaseArray" + i.to_s + " = buildMidiRelease(midiIn" + i.to_s + ")"
  rvrb = SequencerArray[i].split(",")[8]
  pan =  SequencerArray[i].split(",")[15]
  if rvrb.to_i > 0.0
    looperfile.puts "with_fx :reverb, room: " + rvrb.to_s.strip + " do"
    sequencerfile.puts "with_fx :reverb, room: " + rvrb.to_s.strip + " do"      
  end
  if pan.to_i != 0.0
    looperfile.puts "  with_fx :pan, pan: " + pan.to_s.strip + " do"
    sequencerfile.puts "  with_fx :pan, pan: " + pan.to_s.strip + " do"  
  end
  looperfile.puts "    live_loop :sampleloop_Channel" + i.to_s + " do"
  sequencerfile.puts "    live_loop :sampleloop_Channel" + i.to_s + " do"  
  gmBank = SequencerArray[i].split(",")[2]
  gmPatch = SequencerArray[i].split(",")[3]

  newrelease = 0
  paramsArray.each do |paramsRec|
    #puts "gmBank: " + gmBank[2...-1].to_s
    #puts "gmPatch: " + gmPatch[2...-1].to_s
    bank = paramsRec.split(",")[0]
    #puts "bank: " + bank.to_s
    patch = paramsRec.split(",")[1]
    #puts "patch: " + patch.to_s
    if gmBank.to_s[2...-1] == bank.to_s
      if gmPatch.to_s[2...-1] == patch.to_s
        #puts "***************match"
        sustain = paramsRec.split(",")[1]
        decay = paramsRec.split(",")[2]
        release = paramsRec.split(",")[3]
        newrelease = release.to_i
        reverb = paramsRec.split(",")[4]
        chorus = paramsRec.split(",").last        
      end
    end 
  end
  
  amp = SequencerArray[i].split(",")[5]
  rlse = SequencerArray[i].split(",")[7].to_f
  #chrs = SequencerArray[i].split(",")[9]
  #vib =  SequencerArray[i].split(",")[10]
  lpf = SequencerArray[i].split(",")[11]
  fc =  130
  trn =  SequencerArray[i].split(",")[12]
  sBeg =  SequencerArray[i].split(",")[13]
  sEnd = SequencerArray[i].split(",")[14]
  looperfile.puts '      i = tick'
  sequencerfile.puts '      i = tick'   
  looperfile.puts '      instrument noteArray' + i.to_s + '[i].to_i, gmBank: ' + gmBank.to_s.strip + ', gmPatch: ' + gmPatch.to_s.strip + ", gmPathDir: gmPathDir, bpm: bpm, amp: " + amp.to_s.strip + ", release: releaseArray" + i.to_s + "[i].to_f+" + rlse.to_s + ", lpf: " + lpf.to_s.strip
  sequencerfile.puts '      instrument noteArray' + i.to_s + '[i].to_i, gmBank: ' + gmBank.to_s.strip + ', gmPatch: ' + gmPatch.to_s.strip + ", gmPathDir: gmPathDir, bpm: bpm, amp: " + amp.to_s.strip + ", release: releaseArray" + i.to_s + "[i].to_f+" +rlse.to_s + ", lpf: " + lpf.to_s.strip
  looperfile.puts "      sleep timingArray" + i.to_s + "[i].to_f" 
  sequencerfile.puts "      sleep timingArray" + i.to_s + "[i].to_f" 
  looperfile.puts "    end" # end liveloop
  sequencerfile.puts "    end"  
  if rvrb.to_i > 0.0
    looperfile.puts "  end" #  end reverb  
    sequencerfile.puts "  end" 
  end
  if pan.to_i != 0.0
    looperfile.puts "end" #  end pan  
    sequencerfile.puts "end"
  end   
  looperfile.puts " "
  sequencerfile.puts " "  
  looperfile.close

end

sequencerfile.close
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
dumpfile.close