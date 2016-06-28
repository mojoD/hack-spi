# Sonic Pi Midi Loop Prototype

def readMidiLoop (mLoopDir, mLoopIn)
  rNoteArray = []
  mLoopFile = mLoopDir + mLoopIn
  puts "mLoopFile: " + mLoopFile.to_s
  f = File.open(mLoopFile, "r")
  
  rLoopArray = f.readlines # Reads MLoop File into an array
  rActiveArray = "none"
  rLoopArray.each do |element|
    if element[0..2] == "Ins" # get Program (i.e. Instrument)
      rActiveArray = "Program"
    end
    if element[0..4] == "Notes"  # get Notes
      rActiveArray = "Notes"
    end
    if element[0..2] == "Con"   # get Controllers
      rActiveArray = "Controller"
    end
    case rActiveArray
    when "Notes"
      if element[0..4] != "Notes"  # get Notes
        rNoteArray.push element
      end
    end
  end
  return rNoteArray
end

def midiLoopSynthPlayer (loopName, midiProg, midiArray)
  use_synth midiProg
  live_loop loopName do
    numofnotes = midiArray.length
    numofnotes.times do |i|
      #add Velocity as attack?
      noterelease = midiArray[i].split(",")[4].to_f/120
      play midiArray[i].split(",")[5].to_i, release: noterelease
      sleep midiArray[i].split(",")[2].to_i/120.to_f
    end
  end
end

def midiLoopSamplePlayer (loopName, midiProg, midiArray)
  loopIndex = 0
  live_loop loopName do
    msleep = midiArray[loopIndex].split(",")[2].to_i/120.to_f
    if msleep == 0
      msleep = 0.01
    end
    sample midiProg, amp: 2
    sleep msleep
    loopIndex += 1
  end
end

def buildMidiArrays (mLoopDir, mPatchArray, mProgType)
  i = 1
  Dir.foreach(mLoopDir) do |mloops|
    next if mloops == "." or mloops == ".." or mloops == "drums" or mloops == "header.txt" or mloops == "logfile.txt"
    midiArray = []
    midiArray = readMidiLoop(mLoopDir, mloops)
    
    patch = i*3-2
    puts "patch num: " + patch.to_s
    if mProgType == "drums"
      drumTrackNum = i + 34
      loopName = ":sampleloop_Channel" + drumTrackNum.to_s
      midiProg = mPatchArray[patch]
      midiLoopSamplePlayer loopName, midiProg, midiArray
    else
      loopName = ":synthloop_Channel" + i.to_s
      midiProg = mPatchArray[patch]
      midiLoopSynthPlayer loopName, midiProg, midiArray
    end
    i += 1
  end
end

#Define Arrays and Variables used
mNoteArray = []
mLoopIndex = 0
mProgramArray = []

tempo = 180 # read in from file
use_bpm tempo

# The Poor Man's Sonic Pi Midi Sequencer 
# mProgramArray is for non-drum midi instruments (i.e. not midi channel 10). It's format is Channel #, Synth, Volume
mProgramArray = [1, :piano, 1, \
                 2, :pulse, 1, \
                 3, :pluck, 1, \
                 4, :beep, 1, \
                 5, :prophet, 1, \
                 6, :prophet, 1, \
                 7, :pluck, 1, \
                 8, :pretty_bell, 1, \
                 9, :pretty_bell, 1, \
                 11, :piano, 1, \
                 12, :pluck, 1]

# mDrumsArray is for drum midi (i.e. Channel 10). It's format is Channel #, Sample, Volume
mDrumArray = [35, :drum_bass_soft, 1, \
              36, :drum_heavy_kick, 1, \
              37, :tabla_te2, 1, \
              38, :drum_snare_soft, 1, \
              39, :sn_dub, 1, \
              40, :drum_snare_hard, 1, \
              41, :drum_tom_lo_soft, 1, \
              42, :drum_cymbal_closed, 1, \
              43, :drum_tom_hi_hard, 1, \
              44, :drum_cymbal_pedal, 1, \
              45, :drum_tom_hi_soft, 1, \
              46, :drum_cymbal_open, 1, \
              47, :drum_tom_mid_soft, 1, \
              48, :drum_tom_mid_hard, 1, \
              49, :drum_cymbal_hard, 1, \
              50, :drum_tom_mid_hard, 1, \
              51, :drum_cymbal_soft, 1, \
              52, :drum_cymbal_soft, 1, \
              53, :drum_cymbal_soft, 1, \
              54, :drum_cymbal_closed, 1, \
              55, :drum_splash_hard, 1, \
              56, :drum_cowbell, 1, \
              57, :drum_splash_soft, 1, \
              58, :drum_roll, 1, \
              59, :drum_cymbal_soft, 1, \
              60, :tabla_na, 1, \
              61, :tabla_na_o, 1, \
              62, :tabla_dhec, 1, \
              63, :tabla_ghe1, 1, \
              64, :tabla_ghe3, 1, \
              65, :tabla_na, 1, \
              66, :tabla_na_o, 1, \
              67, :tabla_te2, 1, \
              68, :tabla_te2, 1, \
              69, :tabla_te2, 1, \
              70, :tabla_te2, 1, \
              71, :elec_beep, 1, \
              72, :elec_beep, 1, \
              73, :tabla_ghe1, 1, \
              74, :tabla_ghe3, 1, \
              75, :elec_wood, 1, \
              76, :elec_wood, 1, \
              77, :elec_wood, 1, \
              78, :tabla_te2, 1, \
              79, :tabla_te2, 1, \
              80, :elec_triangle, 1, \
              81, :elec_triangle, 1]

mLoopDir = "C:/Users/Michael Sutton/Documents/Midiloops/dreams/"
mDrumDir = mLoopDir + "drums/"

buildMidiArrays mLoopDir, mProgramArray, "instruments"

buildMidiArrays mDrumDir, mDrumArray, "drums"
