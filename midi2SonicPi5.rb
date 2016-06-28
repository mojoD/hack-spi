
#! /usr/bin/env ruby 
# 
# usage: midi2SonicPi5.rb [midi_file_in] [output_directory] 
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

drumArray = []
AcousticBassDrumArray = []
BassDrum1Array = []
SideStickArray = []
AcousticSnareArray = []
HandClapArray = []
ElectricSnareArray = []
LowFloorTomArray = []
ClosedHiHatArray = []
HighFloorTomArray = []
PedalHiHatArray = []
LowTomArray = []
OpenHiHatArray = []
LowMidTomArray = []
HiMidTomArray = []
CrashCymbal1Array = []
HighTomArray = []
RideCymbal1Array = []
ChineseCymbalArray = []
RideBellArray = []
TambourineArray = []
SplashCymbalArray = []
CowbellArray = []
CrashCymbal2Array = []
VibraSlapArray = []
RideCymbal2Array = []
HiBongoArray = []
LowBongoArray = []
MuteHiCongaArray = []
OpenHiCongaArray = []
LowCongaArray = []
HighTimbaleArray = []
LowTimbaleArray = []
HighAgogoArray = []
LowAgogoArray = []
CabasaArray = []
MaracasArray = []
ShortWhistleArray = []
LongWhistleArray = []
ShortGuiroArray = []
LongGuiroArray = []
ClavesArray = []
HiWoodBlockArray = []
LowWoodBlockArray = []
MuteCuicaArray = []
OpenCuicaArray = []
MuteTriangleArray = []
OpenTriangleArray = []

def FindNoteOff (currentArrayPos, currentNote)
  for i in currentArrayPos..ChannelArray.length  
	  if NoteArray[i] == currentNote && StatusArray[i] == "128" 	
      duration = TimeFromStartArray[i].to_f - TimeFromStartArray[currentArrayPos].to_f
	    return duration.to_i
	    break
	  end
  end
end 

def FindDrumNoteOff (currentArrayPos, currentNote, noteArray, statusArray, timeFromStartArray)
  for i in currentArrayPos..noteArray.length  
    if noteArray[i] == currentNote && statusArray[i] == "128"   
      duration = timeFromStartArray[i].to_f - timeFromStartArray[currentArrayPos].to_f
      return duration.to_i
      break
    end
  end
end 

def DrumBuild (drumArray, instrumentname, directoryname, drumtracknum)

  channelArray = []
  timeFromStartArray = []
  statusArray = []
  noteArray = []
  velocityArray = []
  drumArrayPos = 0

  drumArray.each do |element|
    case drumArrayPos.to_s
    when "0"
      channelArray.push(element)
      drumArrayPos = 1
    when "1"
      timeFromStartArray.push(element)
      drumArrayPos = 2
    when "2"
      statusArray.push(element)
      drumArrayPos = 3      
    when "3"
      noteArray.push(element)
      drumArrayPos = 4      
    when "4"
      velocityArray.push(element)
      drumArrayPos = 0      
    end
  end

  currentArrayPos = 0
  prevTimeFromStart = 0
  currentChannel = channelArray[0]
  currentNote = noteArray[0]
  currentStatus = statusArray[0]
  filename = directoryname + "/drums/" + "Track_" + drumtracknum.to_s + "  DrumKit - " + instrumentname + ".mloop"
  puts "filename: " + filename
  drumfile = File.new(filename,"w+")
  drumfile.puts "Notes"

  for i in 0..channelArray.length
    if currentStatus == "144" then
      durationcalc = FindDrumNoteOff currentArrayPos, currentNote, noteArray, statusArray, timeFromStartArray
      if currentArrayPos != 0 then
        deltatime = timeFromStartArray[currentArrayPos].to_i - prevTimeFromStart.to_i
      else
        deltatime = timeFromStartArray[0]
      end
      drumfile.puts channelArray[currentArrayPos] + "," + \
        timeFromStartArray[currentArrayPos] + "," + \
        deltatime.to_s + "," + \
        statusArray[currentArrayPos] + "," + \
        durationcalc.to_s + "," + \
        noteArray[currentArrayPos] + "," + \
        velocityArray[currentArrayPos]
      prevTimeFromStart = timeFromStartArray[currentArrayPos]
    end

    currentArrayPos += 1
    currentChannel = channelArray[currentArrayPos]
    currentNote = noteArray[currentArrayPos]
    currentStatus = statusArray[currentArrayPos]
  end
drumfile.close
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
      headerfile.puts "Tempo: " + e.tempo.to_s + "  msecs per qnote"
    end
    if e.kind_of?(MIDI::KeySig)
      headerfile.puts e.to_s
    end

    # Create Arrays which will be used to create MLOOP Files
    if e.kind_of?(MIDI::NoteEvent)
        # Midi Notes
        if e.channel.to_s != "9" then
	        ChannelArray.push(e.channel.to_s)
	        TimeFromStartArray.push(e.time_from_start.to_s)
	        StatusArray.push(e.status.to_s)
	        NoteArray.push(e.note.to_s)
          VelocityArray.push(e.velocity.to_s)
        else
            #Drum Processing
          case e.note.to_s
          when "35"
            AcousticBassDrumArray.push(e.channel.to_s)
            AcousticBassDrumArray.push(e.time_from_start.to_s)
            AcousticBassDrumArray.push(e.status.to_s)
            AcousticBassDrumArray.push(e.note.to_s)
            AcousticBassDrumArray.push(e.velocity.to_s)
          when "36"
            BassDrum1Array.push(e.channel.to_s)
            BassDrum1Array.push(e.time_from_start.to_s)
            BassDrum1Array.push(e.status.to_s)
            BassDrum1Array.push(e.note.to_s)
            BassDrum1Array.push(e.velocity.to_s)
          when "37"
            SideStickArray.push(e.channel.to_s)
            SideStickArray.push(e.time_from_start.to_s)
            SideStickArray.push(e.status.to_s)
            SideStickArray.push(e.note.to_s)
            SideStickArray.push(e.velocity.to_s)
          when "38"
            AcousticSnareArray.push(e.channel.to_s)
            AcousticSnareArray.push(e.time_from_start.to_s)
            AcousticSnareArray.push(e.status.to_s)
            AcousticSnareArray.push(e.note.to_s)
            AcousticSnareArray.push(e.velocity.to_s)
          when "39"
            HandClapArray.push(e.channel.to_s)
            HandClapArray.push(e.time_from_start.to_s)
            HandClapArray.push(e.status.to_s)
            HandClapArray.push(e.note.to_s)
            HandClapArray.push(e.velocity.to_s)
          when "40"
            ElectricSnareArray.push(e.channel.to_s)
            ElectricSnareArray.push(e.time_from_start.to_s)
            ElectricSnareArray.push(e.status.to_s)
            ElectricSnareArray.push(e.note.to_s)
            ElectricSnareArray.push(e.velocity.to_s)
          when "41"
            LowFloorTomArray.push(e.channel.to_s)
            LowFloorTomArray.push(e.time_from_start.to_s)
            LowFloorTomArray.push(e.status.to_s)
            LowFloorTomArray.push(e.note.to_s)
            LowFloorTomArray.push(e.velocity.to_s)
          when "42"
            ClosedHiHatArray.push(e.channel.to_s)
            ClosedHiHatArray.push(e.time_from_start.to_s)
            ClosedHiHatArray.push(e.status.to_s)
            ClosedHiHatArray.push(e.note.to_s)
            ClosedHiHatArray.push(e.velocity.to_s)
          when "43"
            HighFloorTomArray.push(e.channel.to_s)
            HighFloorTomArray.push(e.time_from_start.to_s)
            HighFloorTomArray.push(e.status.to_s)
            HighFloorTomArray.push(e.note.to_s)
            HighFloorTomArray.push(e.velocity.to_s)
          when "44"
            PedalHiHatArray.push(e.channel.to_s)
            PedalHiHatArray.push(e.time_from_start.to_s)
            PedalHiHatArray.push(e.status.to_s)
            PedalHiHatArray.push(e.note.to_s)
            PedalHiHatArray.push(e.velocity.to_s)
          when "45"
            LowTomArray.push(e.channel.to_s)
            LowTomArray.push(e.time_from_start.to_s)
            LowTomArray.push(e.status.to_s)
            LowTomArray.push(e.note.to_s)
            LowTomArray.push(e.velocity.to_s)
          when "46"
            OpenHiHatArray.push(e.channel.to_s)
            OpenHiHatArray.push(e.time_from_start.to_s)
            OpenHiHatArray.push(e.status.to_s)
            OpenHiHatArray.push(e.note.to_s)
            OpenHiHatArray.push(e.velocity.to_s)
          when "47"
            LowMidTomArray.push(e.channel.to_s)
            LowMidTomArray.push(e.time_from_start.to_s)
            LowMidTomArray.push(e.status.to_s)
            LowMidTomArray.push(e.note.to_s)
            LowMidTomArray.push(e.velocity.to_s)
          when "48"
            HiMidTomArray.push(e.channel.to_s)
            HiMidTomArray.push(e.time_from_start.to_s)
            HiMidTomArray.push(e.status.to_s)
            HiMidTomArray.push(e.note.to_s)
            HiMidTomArray.push(e.velocity.to_s)
          when "49"
            CrashCymbal1Array.push(e.channel.to_s)
            CrashCymbal1Array.push(e.time_from_start.to_s)
            CrashCymbal1Array.push(e.status.to_s)
            CrashCymbal1Array.push(e.note.to_s)
            CrashCymbal1Array.push(e.velocity.to_s)
          when "50"
            HighTomArray.push(e.channel.to_s)
            HighTomArray.push(e.time_from_start.to_s)
            HighTomArray.push(e.status.to_s)
            HighTomArray.push(e.note.to_s)
            HighTomArray.push(e.velocity.to_s)
          when "51"
            RideCymbal1Array.push(e.channel.to_s)
            RideCymbal1Array.push(e.time_from_start.to_s)
            RideCymbal1Array.push(e.status.to_s)
            RideCymbal1Array.push(e.note.to_s)
            RideCymbal1Array.push(e.velocity.to_s)
          when "52"
            ChineseCymbalArray.push(e.channel.to_s)
            ChineseCymbalArray.push(e.time_from_start.to_s)
            ChineseCymbalArray.push(e.status.to_s)
            ChineseCymbalArray.push(e.note.to_s)
            ChineseCymbalArray.push(e.velocity.to_s)
          when "53"
            RideBellArray.push(e.channel.to_s)
            RideBellArray.push(e.time_from_start.to_s)
            RideBellArray.push(e.status.to_s)
            RideBellArray.push(e.note.to_s)
            RideBellArray.push(e.velocity.to_s)
          when "54"
            TambourineArray.push(e.channel.to_s)
            TambourineArray.push(e.time_from_start.to_s)
            TambourineArray.push(e.status.to_s)
            TambourineArray.push(e.note.to_s)
            TambourineArray.push(e.velocity.to_s)
          when "55"
            SplashCymbalArray.push(e.channel.to_s)
            SplashCymbalArray.push(e.time_from_start.to_s)
            SplashCymbalArray.push(e.status.to_s)
            SplashCymbalArray.push(e.note.to_s)
            SplashCymbalArray.push(e.velocity.to_s)
          when "56"
            CowbellArray.push(e.channel.to_s)
            CowbellArray.push(e.time_from_start.to_s)
            CowbellArray.push(e.status.to_s)
            CowbellArray.push(e.note.to_s)
            CowbellArray.push(e.velocity.to_s)
          when "57"
            CrashCymbal2Array.push(e.channel.to_s)
            CrashCymbal2Array.push(e.time_from_start.to_s)
            CrashCymbal2Array.push(e.status.to_s)
            CrashCymbal2Array.push(e.note.to_s)
            CrashCymbal2Array.push(e.velocity.to_s)
          when "58"
            VibraSlapArray.push(e.channel.to_s)
            VibraSlapArray.push(e.time_from_start.to_s)
            VibraSlapArray.push(e.status.to_s)
            VibraSlapArray.push(e.note.to_s)
            VibraSlapArray.push(e.velocity.to_s)        
          when "59"
            RideCymbal2Array.push(e.channel.to_s)
            RideCymbal2Array.push(e.time_from_start.to_s)
            RideCymbal2Array.push(e.status.to_s)
            RideCymbal2Array.push(e.note.to_s)
            RideCymbal2Array.push(e.velocity.to_s)
          when "60"
            HiBongoArray.push(e.channel.to_s)
            HiBongoArray.push(e.time_from_start.to_s)
            HiBongoArray.push(e.status.to_s)
            HiBongoArray.push(e.note.to_s)
            HiBongoArray.push(e.velocity.to_s)
          when "61"
            LowBongoArray.push(e.channel.to_s)
            LowBongoArray.push(e.time_from_start.to_s)
            LowBongoArray.push(e.status.to_s)
            LowBongoArray.push(e.note.to_s)
            LowBongoArray.push(e.velocity.to_s)
          when "62"
            MuteHiCongaArray.push(e.channel.to_s)
            MuteHiCongaArray.push(e.time_from_start.to_s)
            MuteHiCongaArray.push(e.status.to_s)
            MuteHiCongaArray.push(e.note.to_s)
            MuteHiCongaArray.push(e.velocity.to_s)
          when "63"
            OpenHiCongaArray.push(e.channel.to_s)
            OpenHiCongaArray.push(e.time_from_start.to_s)
            OpenHiCongaArray.push(e.status.to_s)
            OpenHiCongaArray.push(e.note.to_s)
            OpenHiCongaArray.push(e.velocity.to_s)
          when "64"
            LowCongaArray.push(e.channel.to_s)
            LowCongaArray.push(e.time_from_start.to_s)
            LowCongaArray.push(e.status.to_s)
            LowCongaArray.push(e.note.to_s)
            LowCongaArray.push(e.velocity.to_s)
          when "65"
            HighTimbaleArray.push(e.channel.to_s)
            HighTimbaleArray.push(e.time_from_start.to_s)
            HighTimbaleArray.push(e.status.to_s)
            HighTimbaleArray.push(e.note.to_s)
            HighTimbaleArray.push(e.velocity.to_s)
          when "66"
            LowTimbaleArray.push(e.channel.to_s)
            LowTimbaleArray.push(e.time_from_start.to_s)
            LowTimbaleArray.push(e.status.to_s)
            LowTimbaleArray.push(e.note.to_s)
            LowTimbaleArray.push(e.velocity.to_s)
          when "67"
            HighAgogoArray.push(e.channel.to_s)
            HighAgogoArray.push(e.time_from_start.to_s)
            HighAgogoArray.push(e.status.to_s)
            HighAgogoArray.push(e.note.to_s)
            HighAgogoArray.push(e.velocity.to_s)
          when "68"
            LowAgogoArray.push(e.channel.to_s)
            LowAgogoArray.push(e.time_from_start.to_s)
            LowAgogoArray.push(e.status.to_s)
            LowAgogoArray.push(e.note.to_s)
            LowAgogoArray.push(e.velocity.to_s)
          when "69"
            CabasaArray.push(e.channel.to_s)
            CabasaArray.push(e.time_from_start.to_s)
            CabasaArray.push(e.status.to_s)
            CabasaArray.push(e.note.to_s)
            CabasaArray.push(e.velocity.to_s)
          when "70"
            MaracasArray.push(e.channel.to_s)
            MaracasArray.push(e.time_from_start.to_s)
            MaracasArray.push(e.status.to_s)
            MaracasArray.push(e.note.to_s)
            MaracasArray.push(e.velocity.to_s)
          when "71"
            ShortWhistleArray.push(e.channel.to_s)
            ShortWhistleArray.push(e.time_from_start.to_s)
            ShortWhistleArray.push(e.status.to_s)
            ShortWhistleArray.push(e.note.to_s)
            ShortWhistleArray.push(e.velocity.to_s)
          when "72"
            LongWhistleArray.push(e.channel.to_s)
            LongWhistleArray.push(e.time_from_start.to_s)
            LongWhistleArray.push(e.status.to_s)
            LongWhistleArray.push(e.note.to_s)
            LongWhistleArray.push(e.velocity.to_s)
          when "73"
            ShortGuiroArray.push(e.channel.to_s)
            ShortGuiroArray.push(e.time_from_start.to_s)
            ShortGuiroArray.push(e.status.to_s)
            ShortGuiroArray.push(e.note.to_s)
            ShortGuiroArray.push(e.velocity.to_s)
          when "74"
            LongGuiroArray.push(e.channel.to_s)
            LongGuiroArray.push(e.time_from_start.to_s)
            LongGuiroArray.push(e.status.to_s)
            LongGuiroArray.push(e.note.to_s)
            LongGuiroArray.push(e.velocity.to_s)
          when "75"
            ClavesArray.push(e.channel.to_s)
            ClavesArray.push(e.time_from_start.to_s)
            ClavesArray.push(e.status.to_s)
            ClavesArray.push(e.note.to_s)
            ClavesArray.push(e.velocity.to_s)
          when "76"
            HiWoodBlockArray.push(e.channel.to_s)
            HiWoodBlockArray.push(e.time_from_start.to_s)
            HiWoodBlockArray.push(e.status.to_s)
            HiWoodBlockArray.push(e.note.to_s)
            HiWoodBlockArray.push(e.velocity.to_s)
          when "77"
            LowWoodBlockArray.push(e.channel.to_s)
            LowWoodBlockArray.push(e.time_from_start.to_s)
            LowWoodBlockArray.push(e.status.to_s)
            LowWoodBlockArray.push(e.note.to_s)
            LowWoodBlockArray.push(e.velocity.to_s)
          when "78"
            MuteCuicaArray.push(e.channel.to_s)
            MuteCuicaArray.push(e.time_from_start.to_s)
            MuteCuicaArray.push(e.status.to_s)
            MuteCuicaArray.push(e.note.to_s)
            MuteCuicaArray.push(e.velocity.to_s)
          when "79"
            OpenCuicaArray.push(e.channel.to_s)
            OpenCuicaArray.push(e.time_from_start.to_s)
            OpenCuicaArray.push(e.status.to_s)
            OpenCuicaArray.push(e.note.to_s)
            OpenCuicaArray.push(e.velocity.to_s)
          when "80"
            MuteTriangleArray.push(e.channel.to_s)
            MuteTriangleArray.push(e.time_from_start.to_s)
            MuteTriangleArray.push(e.status.to_s)
            MuteTriangleArray.push(e.note.to_s)
            MuteTriangleArray.push(e.velocity.to_s)
          when "81"
            OpenTriangleArray.push(e.channel.to_s)
            OpenTriangleArray.push(e.time_from_start.to_s)
            OpenTriangleArray.push(e.status.to_s)
            OpenTriangleArray.push(e.note.to_s)
            OpenTriangleArray.push(e.velocity.to_s)
          else
            # Not a Drum
          end
        end
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
  
  # Build the MLOOP file for the Track if the track has notes in it
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
    filename = directoryname.to_s + "/" + "Track" + "_" + strtrackcntr + " - " + trackfilename.to_s + " - " + instrumentname.to_s + ".mloop"
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
      else
        #outfile.puts "Drums"
    end

    # Output Controller Changes
    currentArrayPos = 0
    outfile.puts "Controller Changes"
    if ControllerVolumeArray.length != 0
      for i in 0..ControllerVolumeArray.length-1
        outfile.puts ControllerVolumeArray[currentArrayPos]
        currentArrayPos += 1
      end
    end

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
  else
    drumdirectoryname = directoryname + "/drums"
    puts drumdirectoryname
    Dir.mkdir(drumdirectoryname) unless File.exists?(drumdirectoryname)

    if AcousticBassDrumArray.length > 0
      drumtracknum = "35"
      drumArray = AcousticBassDrumArray
      instrumentname = "AcousticBassDrumArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if BassDrum1Array.length > 0
      drumtracknum = "36"
      drumArray = BassDrum1Array
      instrumentname = "BassDrum1Array"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end    
    if SideStickArray.length > 0
      drumtracknum = "37"
      drumArray = SideStickArray
      instrumentname = "SideStickArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if AcousticSnareArray.length > 0
      drumtracknum = "38"
      drumArray = AcousticSnareArray
      instrumentname = "AcousticSnareArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HandClapArray.length > 0
      drumtracknum = "39"
      drumArray = HandClapArray
      instrumentname = "HandClapArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ElectricSnareArray.length > 0
      drumtracknum = "40"
      drumArray = ElectricSnareArray
      instrumentname = "ElectricSnareArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowFloorTomArray.length > 0
      drumtracknum = "41"
      drumArray = LowFloorTomArray
      instrumentname = "LowFloorTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ClosedHiHatArray.length > 0
      drumtracknum = "42"
      drumArray = ClosedHiHatArray
      instrumentname = "ClosedHiHatArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HighFloorTomArray.length > 0
      drumtracknum = "43"
      drumArray = HighFloorTomArray
      instrumentname = "HighFloorTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if PedalHiHatArray.length > 0
      drumtracknum = "44"
      drumArray = PedalHiHatArray
      instrumentname = "PedalHiHatArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowTomArray.length > 0
      drumtracknum = "45"
      drumArray = LowTomArray
      instrumentname = "LowTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if OpenHiHatArray.length > 0
      drumtracknum = "46"
      drumArray = OpenHiHatArray
      instrumentname = "OpenHiHatArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowMidTomArray.length > 0
      drumtracknum = "47"
      drumArray = LowMidTomArray
      instrumentname = "LowMidTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HiMidTomArray.length > 0
      drumtracknum = "48"
      drumArray = HiMidTomArray
      instrumentname = "HiMidTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if CrashCymbal1Array.length > 0
      drumtracknum = "49"
      drumArray = CrashCymbal1Array
      instrumentname = "CrashCymbal1Array"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HighTomArray.length > 0
      drumtracknum = "50"
      drumArray = HighTomArray
      instrumentname = "HighTomArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if RideCymbal1Array.length > 0
      drumtracknum = "51"
      drumArray = RideCymbal1Array
      instrumentname = "RideCymbal1Array"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ChineseCymbalArray.length > 0
      drumtracknum = "52"
      drumArray = ChineseCymbalArray
      instrumentname = "ChineseCymbalArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if RideBellArray.length > 0
      drumtracknum = "53"
      drumArray = RideBellArray
      instrumentname = "RideBellArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if TambourineArray.length > 0
      drumtracknum = "54"
      drumArray = TambourineArray
      instrumentname = "TambourineArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if SplashCymbalArray.length > 0
      drumtracknum = "55"
      drumArray = SplashCymbalArray
      instrumentname = "SplashCymbalArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if CowbellArray.length > 0
      drumtracknum = "56"
      drumArray = CowbellArray
      instrumentname = "CowbellArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if CrashCymbal2Array.length > 0
      drumtracknum = "57"
      drumArray = CrashCymbal2Array
      instrumentname = "CrashCymbal2Array"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if VibraSlapArray.length > 0
      drumtracknum = "58"
      drumArray = VibraSlapArray
      instrumentname = "VibraSlapArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if RideCymbal2Array.length > 0
      drumtracknum = "59"
      drumArray = RideCymbal2Array
      instrumentname = "RideCymbal2Array"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HiBongoArray.length > 0
      drumtracknum = "60"
      drumArray = HiBongoArray
      instrumentname = "HiBongoArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowBongoArray.length > 0
      drumtracknum = "61"
      drumArray = LowBongoArray
      instrumentname = "LowBongoArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if MuteHiCongaArray.length > 0
      drumtracknum = "62"
      drumArray = MuteHiCongaArray
      instrumentname = "MuteHiCongaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if OpenHiCongaArray.length > 0
      drumtracknum = "63"
      drumArray = OpenHiCongaArray
      instrumentname = "OpenHiCongaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowCongaArray.length > 0
      drumtracknum = "64"
      drumArray = LowCongaArray
      instrumentname = "LowCongaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HighTimbaleArray.length > 0
      drumtracknum = "65"
      drumArray = HighTimbaleArray
      instrumentname = "HighTimbaleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowTimbaleArray.length > 0
      drumtracknum = "66"
      drumArray =LowTimbaleArray
      instrumentname = "LowTimbaleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HighAgogoArray.length > 0
      drumtracknum = "67"
      drumArray = HighAgogoArray
      instrumentname = "HighAgogoArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowAgogoArray.length > 0
      drumtracknum = "68"
      drumArray = LowAgogoArray
      instrumentname = "LowAgogoArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if CabasaArray.length > 0
      drumtracknum = "69"
      drumArray = CabasaArray
      instrumentname = "CabasaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if MaracasArray.length > 0
      drumtracknum = "70"
      drumArray = MaracasArray
      instrumentname = "MaracasArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ShortWhistleArray.length > 0
      drumtracknum = "71"
      drumArray = ShortWhistleArray
      instrumentname = "ShortWhistleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LongWhistleArray.length > 0
      drumtracknum = "72"
      drumArray = LongWhistleArray
      instrumentname = "LongWhistleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ShortGuiroArray.length > 0
      drumtracknum = "73"
      drumArray = ShortGuiroArray
      instrumentname = "ShortGuiroArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LongGuiroArray.length > 0
      drumtracknum = "74"
      drumArray = LongGuiroArray
      instrumentname = "LongGuiroArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if ClavesArray.length > 0
      drumtracknum = "75"
      drumArray = ClavesArray
      instrumentname = "ClavesArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if HiWoodBlockArray.length > 0
      drumtracknum = "76"
      drumArray = HiWoodBlockArray
      instrumentname = "HiWoodBlockArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if LowWoodBlockArray.length > 0
      drumtracknum = "77"
      drumArray = LowWoodBlockArray
      instrumentname = "LowWoodBlockArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if MuteCuicaArray.length > 0
      drumtracknum = "78"
      drumArray = MuteCuicaArray
      instrumentname = "MuteCuicaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if OpenCuicaArray.length > 0
      drumtracknum = "79"
      drumArray = OpenCuicaArray
      instrumentname = "OpenCuicaArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if MuteTriangleArray.length > 0
      drumtracknum = "80"
      drumArray = MuteTriangleArray
      instrumentname = "MuteTriangleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end
    if OpenTriangleArray.length > 0
      drumtracknum = "81"
      drumArray = OpenTriangleArray
      instrumentname = "OpenTriangleArray"
      DrumBuild drumArray, instrumentname, directoryname, drumtracknum
    end

  end 

end

logfile.close
headerfile.close
