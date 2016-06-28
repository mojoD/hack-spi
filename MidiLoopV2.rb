# Sonic Pi Midi Loop Prototype

def readMidiLoop (mLoopIn)
  rNoteArray = []
  f = File.open(mLoopIn, "r")
  
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

#Define Arrays and Variables used
mNoteArray = []
mLoopIndex = 0

#Bring in Midi Loop
tempo = 180 # read in from file
use_bpm tempo
mLoopDir = "C:/Users/Michael Sutton/Documents/sonicpi/dreams/"
mLoopIn1 = mLoopDir + "Track_DREAMS              - Bright Acoustic Piano.mloop"
mLoopIn2 = mLoopDir + "Track_DREAMS            2 - Electric Bass (finger).mloop"
mLoopIn3 = mLoopDir + "Track_DREAMS            3 - Acoustic Guitar (steel).mloop"
mLoopIn4 = mLoopDir + "Track_DREAMS            4 - Flute.mloop"
mLoopIn5 = mLoopDir + "Track_DREAMS            5 - Synth Voice.mloop"
mLoopIn6 = mLoopDir + "Track_DREAMS            6 - Synth Voice.mloop"
mLoopIn7 = mLoopDir + "Track_DREAMS            7 - Electric Guitar (jazz).mloop"
mLoopIn8 = mLoopDir + "Track_DREAMS            8 - String Ensemble 1.mloop"
mLoopIn9 = mLoopDir + "Track_DREAMS            9 - String Ensemble 2.mloop"
mLoopIn10A = mLoopDir + "drums/Track_DrumKit - AcousticBassDrumArray.mloop"
mLoopIn10B = mLoopDir + "drums/Track_DrumKit - ElectricSnareArray.mloop"
mLoopIn10C = mLoopDir + "drums/Track_DrumKit - HighFloorTomArray.mloop"
mLoopIn10D = mLoopDir + "drums/Track_DrumKit - HighTomArray.mloop"
mLoopIn10E = mLoopDir + "drums/Track_DrumKit - HiMidTomArray.mloop"
mLoopIn10F = mLoopDir + "drums/Track_DrumKit - LowMidTomArray.mloop"
mLoopIn10G = mLoopDir + "drums/Track_DrumKit - LowTomArray.mloop"
mLoopIn10H = mLoopDir + "drums/Track_DrumKit - ClosedHiHatArray.mloop"
mLoopIn10I = mLoopDir + "drums/Track_DrumKit - CrashCymbal1Array.mloop"
mLoopIn10J = mLoopDir + "drums/Track_DrumKit - CrashCymbal2Array.mloop"
mLoopIn10K = mLoopDir + "drums/Track_DrumKit - OpenHiHatArray.mloop"
mLoopIn10L = mLoopDir + "drums/Track_DrumKit - PedalHiHatArray.mloop"
mLoopIn10M = mLoopDir + "drums/"
mLoopIn10N = mLoopDir + "drums/"
mLoopIn11 = mLoopDir + "Track_DREAMS           11 - Vibraphone.mloop"
mLoopIn12 = mLoopDir + "Track_DREAMS           12 - Guitar harmonics.mloop"

mNoteArray1 = readMidiLoop(mLoopIn1)
mNoteArray2 = readMidiLoop(mLoopIn2)
mNoteArray3 = readMidiLoop(mLoopIn3)
mNoteArray4 = readMidiLoop(mLoopIn4)
mNoteArray5 = readMidiLoop(mLoopIn5)
mNoteArray6 = readMidiLoop(mLoopIn6)
mNoteArray7 = readMidiLoop(mLoopIn7)
mNoteArray8 = readMidiLoop(mLoopIn8)
mNoteArray9 = readMidiLoop(mLoopIn9)
mNoteArray10A = readMidiLoop(mLoopIn10A) #drums
mNoteArray10B = readMidiLoop(mLoopIn10B) #drums
mNoteArray10C = readMidiLoop(mLoopIn10C) #drums
mNoteArray10D = readMidiLoop(mLoopIn10D) #drums
mNoteArray10E = readMidiLoop(mLoopIn10E) #drums
mNoteArray10F = readMidiLoop(mLoopIn10F) #drums
mNoteArray10G = readMidiLoop(mLoopIn10G) #drums
mNoteArray10H = readMidiLoop(mLoopIn10H) #drums
mNoteArray10I = readMidiLoop(mLoopIn10I) #drums
mNoteArray10J = readMidiLoop(mLoopIn10J) #drums
mNoteArray10K = readMidiLoop(mLoopIn10K) #drums
mNoteArray10L = readMidiLoop(mLoopIn10L) #drums
mNoteArray11 = readMidiLoop(mLoopIn11)
mNoteArray12 = readMidiLoop(mLoopIn12)


use_synth :piano
live_loop :synthmloop_Channel_1 do
  numofnotes = mNoteArray1.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray1[i].split(",")[4].to_f/120
    play mNoteArray1[i].split(",")[5].to_i, release: noterelease
    sleep mNoteArray1[i].split(",")[2].to_i/120.to_f
  end
end

use_synth :pulse
live_loop :synthmloop_Channel_2 do
  numofnotes = mNoteArray2.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray2[i].split(",")[4].to_f/120
    play note: mNoteArray2[i].split(",")[5].to_i, release: noterelease, cutoff: 50
    sleep mNoteArray2[i].split(",")[2].to_f/120
  end
end

use_synth :pluck
live_loop :synthmloop_Channel_3 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :beep
live_loop :synthmloop_Channel_4 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :prophet
live_loop :synthmloop_Channel_5 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :prophet
live_loop :synthmloop_Channel_6 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end
use_synth :pluck
live_loop :synthmloop_Channel_7 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end
use_synth :dsaw
live_loop :synthmloop_Channel_8 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :dsaw
live_loop :synthmloop_Channel_9 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :piano
live_loop :synthmloop_Channel_11 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

use_synth :pluck
live_loop :synthmloop_Channel_12 do
  numofnotes = mNoteArray3.length
  numofnotes.times do |i|
    #add Velocity as attack?
    noterelease = mNoteArray3[i].split(",")[4].to_f/120
    play mNoteArray3[i].split(",")[5].to_i, release: noterelease, amp: 1
    sleep mNoteArray3[i].split(",")[2].to_f/120
  end
end

###### Drums ######
mLoopIndexA = 0
live_loop :Channel_10_DrumA do
  msleepA = mNoteArray10A[mLoopIndexA].split(",")[2].to_i/120.to_f
  if msleepA == 0
    msleepA = 0.01
  end
  sample :drum_bass_soft, amp: 1
  sleep msleepA
  mLoopIndexA += 1
end

mLoopIndexB = 0
live_loop :Channel_10_DrumB do
  msleepB = mNoteArray10B[mLoopIndexB].split(",")[2].to_i/120.to_f
  if msleepB == 0
    msleepB = 0.01
  end
  sample :drum_snare_hard, amp: 1
  sleep msleepB
  mLoopIndexB += 1
end

mLoopIndexC = 0
live_loop :Channel_10_DrumC do
  msleep = mNoteArray10C[mLoopIndexC].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_tom_hi_hard, amp: 1
  sleep msleep
  mLoopIndexC += 1
end

mLoopIndexD = 0
live_loop :Channel_10_DrumD do
  msleep = mNoteArray10D[mLoopIndexD].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_tom_mid_hard, amp: 1
  sleep msleep
  mLoopIndexD += 1
end

mLoopIndexE = 0
live_loop :Channel_10_DrumE do
  msleep = mNoteArray10E[mLoopIndexE].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_tom_mid_soft, amp: 1
  sleep msleep
  mLoopIndexE += 1
end

mLoopIndexF = 0
live_loop :Channel_10_DrumF do
  msleep = mNoteArray10F[mLoopIndexF].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_tom_lo_hard, amp: 1
  sleep msleep
  mLoopIndexF += 1
end

mLoopIndexG = 0
live_loop :Channel_10_DrumG do
  msleep = mNoteArray10G[mLoopIndexG].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_tom_mid_soft, amp: 1
  sleep msleep
  mLoopIndexG += 1
end

mLoopIndexH = 0
live_loop :Channel_10_DrumH do
  msleep = mNoteArray10H[mLoopIndex].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_cymbal_closed, amp: 1
  sleep msleep
  mLoopIndexH += 1
end

mLoopIndexI = 0
live_loop :Channel_10_DrumI do
  msleep = mNoteArray10I[mLoopIndexI].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_cymbal_hard, amp: 1
  sleep msleep
  mLoopIndexI += 1
end

mLoopIndexJ = 0
live_loop :Channel_10_DrumJ do
  msleep = mNoteArray10J[mLoopIndexJ].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_cymbal_hard, amp: 1
  sleep msleep
  mLoopIndexJ += 1
end

mLoopIndexK = 0
live_loop :Channel_10_DrumK do
  msleep = mNoteArray10K[mLoopIndexK].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_cymbal_open, amp: 1
  sleep msleep
  mLoopIndexK += 1
end

mLoopIndexL = 0
live_loop :Channel_10_DrumL do
  msleep = mNoteArray10L[mLoopIndexL].split(",")[2].to_i/120.to_f
  if msleep == 0
    msleep = 0.01
  end
  sample :drum_cymbal_pedal, amp: 1
  sleep msleep
  mLoopIndexL += 1
end