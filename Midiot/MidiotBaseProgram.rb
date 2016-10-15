#!/usr/bin/env ruby -rubygems
# Sonic Pi Midiot Base Program V0

require "FileUtils"
#require 'socket'

def getBPM (mLoopDir)
  headerfile = mLoopDir + "header.txt"
  f = File.open(headerfile, "r")
  headerArray = f.readlines
  bpm = 100
  headerArray.each do |headline|
    if headline[0..2] == "BPM"
      bpm = headline[5..headline.length.to_i]
    end
  end
  return bpm
end

def getkeyIn (mLoopDir)
  headerfile = mLoopDir + "header.txt"
  f = File.open(headerfile, "r")
  headerArray = f.readlines
  keyIn = "C"
  headerArray.each do |headline|
    if headline[0..2] == "key"
      keyIn = headline[5..headline.length.to_i]
    end
  end
  return keyIn
end

def getscaleIn (mLoopDir)
  headerfile = mLoopDir + "header.txt"
  f = File.open(headerfile, "r")
  headerArray = f.readlines
  scaleIn = "minor"
  headerArray.each do |headline|
    if headline[0..4] == "scale"
      scaleIn = headline[7..headline.length.to_i]
    end
  end
  return scaleIn
end

def getSample (sampleFileName, gMPathDir)
  #puts "sampleFileName: " + sampleFileName.to_s
  #puts "gMPathDir: " + gMPathDir.to_s
  sampleFile = File.open(sampleFileName, "r")
  sampleArray = sampleFile.readlines # Reads Sample File into an array
  sampleFile.close
  prevSample = " "
  sampleArray.each do |sampleLine|
    currentSample = sampleLine.split(",")[3]
    #puts "prevSample: " + prevSample.to_s
    #puts "currentSample: " + currentSample.to_s
    if currentSample != prevSample
      externalSample = gMPathDir + currentSample + ".wav"
      puts "externalSample: " + externalSample.to_s
      load_sample externalSample, amp: 0.1
      prevSample = currentSample
    end
  end
  return sampleArray
end

def midiSlice(sliceIn)
  sliceMeasure = sliceIn.split(".")[0]
  sliceBeat = sliceIn.split(".")[1]
  sliceTick = sliceIn.split(".")[2]
  sliceOut = ((sliceMeasure.to_i - 1) * 480) + ((sliceBeat.to_i - 1) * 120) + sliceTick.to_i
  return sliceOut
end

def readMidiLoop (mloopDir: " ", mloop: " ", sliceBegin: "1.1.0", sliceLength: "-1", transpose: 0, noteFilter: -1)
  rNoteArray = [] 
  rLoopArray2 = []
  noteFlag = "N"
  mLoopFile = mloopDir + mloop
  midiSliceBegin = ""
  f = File.open(mLoopFile, "r")
  rLoopArray = f.readlines # Reads MLoop File into an array
  
  if noteFilter.to_s == "-1"
    #do nothing
  else 
    #spin thru array and delete non matching notes
    rLoopArray.each do |element|

      if noteFlag == "Y"    
        noteToCheck = element.split(",")[5].to_s
        #puts "noteToCheck: " + noteToCheck.to_s
        #puts "noteFilter: " + noteFilter.to_s
        if noteToCheck.to_i == noteFilter.to_i
          rLoopArray2.push element
        end
      else 
        rLoopArray2.push element        
      end
      if element[0..4] == "Notes"  # get Notes
        noteFlag = "Y"          
      end      
    end  
    #recalculate note durations
    noteFlag = "N"
    i = 0
    rLoopArray = []
    rLoopArray2Length = rLoopArray2.length
    rLoopArray2.each do |element|  
      if noteFlag == "Y"
        if i < rLoopArray2.length.to_i
          midiStr = element.to_s  
          durationRec = rLoopArray2[i+2]
          if i.to_i < rLoopArray2Length.to_i-2
            nextTick = durationRec.split(",")[1].to_i
          else
            nextTick = 120 #arbitrary last note length
          end
          currentTick =  midiStr.split(",")[1]
          newDuration =  nextTick.to_i - currentTick.to_i
          newMLoopLine = midiStr.split(",")[0] + "," + midiStr.split(",")[1] + "," + newDuration.to_s + "," + midiStr.split(",")[3] + "," + midiStr.split(",")[4] + "," + midiStr.split(",")[5].to_s + "," + midiStr.split(",")[6]          
          rLoopArray.push newMLoopLine
        end
      else
        rLoopArray.push element     
      end
      if element[0..4] == "Notes"  # get Notes
        noteFlag = "Y"       
      end
      i += 1
    end
  end 

  if sliceLength.to_s.include? "." # has legitimate beat.measure.ticks slice requested
    if sliceBegin.to_s.include? "-1" # if -1 then set begin to 1 tick past 0.0.0
      loopcntr = 0
      rLoopArray.each do |element|
        if element[0..4] == "Notes"  # get Notes
          testSliceBegin = rLoopArray[loopcntr+2] # get second event in notes
          midiSliceBegin = testSliceBegin.split(",")[1].to_i
          break
        end
        loopcntr += 1
      end      
    else
      midiSliceBegin = midiSlice(sliceBegin)
    end
    midiSliceEnd = midiSlice(sliceLength) + midiSliceBegin
  end
  noteFlag = "N"
  rLoopArray.each do |element|
    #puts "element: " + element.to_s
  end
  rLoopArray.each do |element|
    if noteFlag == "Y"      
      newNote = element.split(",")[5].to_i + transpose.to_i
      midiStr = element.to_s
      newMLoopLine = midiStr.split(",")[0] + "," + midiStr.split(",")[1] + "," + midiStr.split(",")[2] + "," + midiStr.split(",")[3] + "," + midiStr.split(",")[4] + "," + newNote.to_s + "," + midiStr.split(",")[6]        
      if sliceLength.to_s.include? "-1"
        rNoteArray.push newMLoopLine
      elsif element.split(",")[1].to_i >= midiSliceBegin.to_i
        if element.split(",")[1].to_i <= midiSliceEnd.to_i
          rNoteArray.push newMLoopLine  
        end
      end
    end
    if element[0..4] == "Notes"  # get Notes
      noteFlag = "Y"
    end
  end
  rNoteArray.each do |element|
    #puts "element: " + element.to_s
  end

  f.close

  return rNoteArray
end

def listMidiNotes(midiNoteArrayIn)
  puts "listMidiNotes - unique midi notes"
  uniqueMidiNotes = []
  127.times do |j|
    uniqueMidiNotes[j] = 0
  end
  for i in 0..midiNoteArrayIn.length.to_i
    uniqueMidiNotes[midiNoteArrayIn[i].to_i] = 1
  end
  127.times do |j|
    if uniqueMidiNotes[j] == 1
      puts "note: " + j.to_s
    end
  end
end

def buildMidiNotes(midiArrayIn)
  midiNoteArray = []
  numofnotes = midiArrayIn.length
  numofnotes.times do |i|
    #puts "i: " + i.to_s + " note: " + midiArrayIn[i].to_s 
    noteToPlay = midiArrayIn[i].split(",")[5].to_f
    midiNoteArray.push noteToPlay
  end
  puts "midiNoteArray: " + midiNoteArray.to_s
  return midiNoteArray
end

def buildMidiTiming(midiArrayIn)
  midiTimingArray = []
  numofnotes = midiArrayIn.length
  numofnotes.times do |i|    
    if i.to_i < (numofnotes.to_i - 1)
      msleep = midiArrayIn[i+1].split(",")[2].to_i/120.to_f  #time until next note plays
      msleep = msleep.round(2)
    else
      msleep = 1
    end
    if msleep.to_f == 0.0
      msleep = 0.0000000001
    end
    midiTimingArray.push msleep
  end
  puts "midiTimingArray: " + midiTimingArray.to_s
  return midiTimingArray
end

def buildMidiRelease(midiArrayIn)
  midiReleaseArray = []
  numofnotes = midiArrayIn.length
  numofnotes.times do |i|
    noteRelease = midiArrayIn[i].split(",")[4].to_f/120
    midiReleaseArray.push noteRelease
  end
  puts "midiReleaseArray: " + midiReleaseArray.to_s
  return midiReleaseArray
end


#add all the parameters for each synth
##### Dead Code
def midisynth (synthName=:beep, midiArray=" ", amp: 1.0, amp_slide: 1, pan: 0, pan_slide: 1, attack: -1, decay: -1, sustain: -1, release: -1, attack_level: -1, decay_level: -1, sustain_level: -1, env_curve: -1, slide: -1, pitch: -1)
  #add case statement for each synth to set parameters
  use_synth synthName
  numofnotes = midiArray.length
  numofnotes.times do |i|
    if i.to_i < (numofnotes.to_i - 1)
      msleep = midiArray[i+1].split(",")[2].to_i/120.to_f  #time until next note plays
      msleep = msleep.round(2)
    else
      msleep = 1
    end
    noterelease = midiArray[i].split(",")[4].to_f/120
    noteToPlay = midiArray[i].split(",")[5].to_f
    play noteToPlay, amp: amp
    sleep msleep
  end
end

def samplePlayer (i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack=0.01, decay=0.3, sustain=0.5, releaseTime=0.1, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, panIn, midiFlag)
 
  instrumentPlaying = presetSettings.split(",")[7]
  if midiFlag == "Y"
    sampleRec = sampleArray[i].to_s
    noteRelease = duration.to_f#releaseTime.to_f
  else
    sampleRec = sampleArray[i].to_s # using note number from the midi record as an index get the record from pisf for that note
    noteRelease = duration * 120
  end

  rateToPlay = sampleRec.split(",")[2].to_f # rate is the second parm
  
  sampleToPlay = gmPathDir.to_s + sampleRec.split(",")[3].to_s + ".wav" # build the name of the wav file from third parm
  sampleRate = sampleRec.split(",")[4].to_f # sample rate
  sampleFrames = sampleRec.split(",")[5].to_f # number of frames in the full sample
  sampleTime = sampleRec.split(",")[6].to_f # time in seconds of the full sample
  startLoop = sampleRec.split(",")[7].to_f # frame of the start of the sustaining loop
  endLoop = sampleRec.split(",")[8].to_f # frame of the end of the sustaining loop
  loopFrames = sampleRec.split(",")[9].to_f # number of frames in the sustaining loop
  lpfFreqCutoffSonicPi = (440*(2**((lpfFreqCutoff.to_i-69).to_f/12).to_f)).floor
  hpfFreqCutoffSonicPi = (440*(2**((hpfFreqCutoff.to_i-69).to_f/12).to_f)).floor
  
  #calcuate number of times to repeat the sustaining loop
  ticksPerMin = bpm*120 # beats per minute * ticks per beat
  noteDurationInSecs = noteRelease.to_f / ticksPerMin.to_f * 60 # how many ticks the note plays for divided by ticks in a minute times 60 seconds in a minute
  #noteDurationInSecs = noteRelease.to_f * 60 / bpm
  noteDurationInFrames = sampleRate * noteDurationInSecs # sample rate is frames per second * number of seconds the note is held for
  finish = noteDurationInFrames.to_f / sampleFrames.to_f
  sustainTime = noteDurationInSecs / sampleTime
 
  if duration == 999.0 # from midithru set it so it plays the sample instead of the wav looper
    noteDurationInFrames = sampleFrames - 1
  end

  if noteDurationInFrames > sampleFrames # stretch the sample
    numOfLoops = (((noteDurationInFrames - sampleFrames) / loopFrames) + 1).floor # you add 1 back in because the loop needs to play for first time through the sample
    synth "sonic-pi-wav_looper", buf: load_sample_at_path(sampleToPlay).id, startLoop: startLoop, endLoop: endLoop, numOfTimes: numOfLoops, amp: amp, rateShift: rateToPlay, lpfFreq: lpfFreqCutoffSonicPi, hpfFreq: hpfFreqCutoffSonicPi, panIn: panIn, attack: attack, decay: decay, sustain: sustain, release: releaseTime
  else
    if sampleFrames != 0
      releaseTime = 0.1
      #sample sampleToPlay, rate: rateToPlay, amp: amp, sustain: sustain, attack: attack, decay: decay, release: releaseTime, finish: finish.to_f, lpf: lpfFreqCutoff.to_f, hpf: hpfFreqCutoff.to_f, pan: panIn # play on part of the sample
      sample sampleToPlay, rate: rateToPlay, amp: amp, release: 0.1, finish: finish.to_f, lpf: lpfFreqCutoff.to_f, hpf: hpfFreqCutoff.to_f, pan: panIn # play on part of the sample            
    else
      releaseTime = 0.1
      sample sampleToPlay, rate: rateToPlay, amp: amp, lpf: lpfFreqCutoff.to_f, hpf: hpfFreqCutoff.to_f, pan: panIn # cannot play a partial sample because don't know sampleFrames
    end
  end 
end

##### Dead Code ######
def midiSamplePlayer (gmPathDir, midiArray, sampleArray, presetSettings, attack, decay, sustain, releaseTime, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, glIn, glFunc, midiFlag)
  loopFor = midiArray[0]
  midiArray = midiArray.drop(1)
  numofnotes = midiArray.length

  puts "midiFlag in midiSamplePlayer: " + midiFlag.to_s

  loopFor.to_i.times do 
    numofnotes.times do |i|
      if i.to_i < (numofnotes.to_i - 1)
        msleep = midiArray[i+1].split(",")[2].to_i/120.to_f  #time until next note plays
        msleep = msleep.round(3)
      else
        msleep = 0.0
      end
      samplePlayer i, "N", gmPathDir, sampleArray, midiArray, presetSettings, attack, sustain, decay, releaseTime, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, midiFlag
      sleep msleep
      if glIn.to_s != "none"
        glmidi glIn.to_s
      end
      if glFunc.to_s != "none"
        case glFunc
        when "gl1"
          gl1
        when "gl2"
          gl2
        when "gl3"
          gl3
        when "gl4"
          gl4
        when "gl5"
          gl5
        when "gl6"
          gl6
        when "gl7"
          gl7
        when "gl8"          
          gl8   
        when "gl9"
          gl9
        when "gl10"
          gl10
        when "gl11"
          gl11
        when "gl12"
          gl12
        when "gl13"
          gl13
        when "gl14"
          gl14
        when "gl15"
          gl15
        when "gl16"          
          gl16                  
        end  
      end

    end
  end
  stop
end
##### End of Dead Code


def instrument(midiIn, duration: 1.0, gmBank: "000", gmPatch: "000", gmPathDir: "C:/Users/Michael Sutton/Midiloop/default/", amp: 1.0, attack: 0.01, decay: 0.3, sustain: 0.5, release: 1.0, lpf: 128, hpf: 1, bpm: 60, pan: 0.0, glIn: "none", glFunc: "none", midiFlag: "N")  

  if gmPathDir[0] == "'"
    testPathDir = gmPathDir[1...-1]
  end
  if gmBank[0] == "'"
    testBank = gmBank[1...-1]
  end
  if gmPatch[0] == "'"
    testPatch = gmPatch[1...-1]
  end
  if gmPathDir[0] == "'"  
    sMixerPresetArray = buildGMSampleArray(testPathDir, testBank, testPatch)
  else
    sMixerPresetArray = buildGMSampleArray(gmPathDir, gmBank, gmPatch)
  end
  presetMixerLineForPatch = sMixerPresetArray[0]
  presetMixerLineForPatchLength = presetMixerLineForPatch.length
  presetSettings = presetMixerLineForPatch[8..presetMixerLineForPatch.length].partition(",").last
  
  sampleToPlay = presetSettings.split(",")[7]
  if gmPathDir[0] == "'" 
    sampleFileName = gmPathDir + sampleToPlay + ".pisf"
    sampleArray = getSample(sampleFileName, gmPathDir)    
  else
    sampleFileName = gmPathDir + sampleToPlay + ".pisf"
    puts "sampleFileName: " + sampleFileName.to_s
    sampleArray = getSample(sampleFileName, gmPathDir)    
  end

  
  if lpf.to_i > 128 # override Frequency is not set so use the FC in the preset file
    lpfFreqCutoff = presetSettings.split(",")[4].to_f.floor
  else
    lpfFreqCutoff = lpf
  end
  if hpf.to_i < 2 # override Frequency is not set so use the FC in the preset file
    #hpfFreqCutoff = presetSettings.split(",")[4].to_f.floor
    hpfFreqCutoff = hpf
  else
    hpfFreqCutoff = hpf
  end

  ### Dead cide
  if midiIn.instance_of? Array  
    if midiIn[0].instance_of? String
      midiSamplePlayer gmPathDir, midiIn, sampleArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, glIn, glFunc, midiFlag
    end
  end
  ##### 

  if midiIn.instance_of? Symbol
    midiArray = []
    midiInStr = midiIn
    if gmPathDir[0] == "'" 
      samplePlayer midiIn.to_i, duration, testPathDir, sampleArray, midiArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, midiFlag
    else
      samplePlayer midiIn.to_i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, midiFlag
    end
  end
  if midiIn.kind_of? Integer
    if gmPathDir[0] == "'"
      if midiIn.to_i != -1    
        samplePlayer midiIn.to_i, duration, testPathDir, sampleArray, midiArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, midiFlag
      end
    else
      if midiIn.to_i != -1
        samplePlayer midiIn.to_i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, midiFlag
      end
    end
  end
end

def buildGMSampleArray(gmDirIn, gmBank, gmPatch)

  sGMArray = []
  sMixerPresetArray = []
  sampleFlag = "N"
  sGMFileName = gmDirIn + ".presets.info"

  sGMFile = File.open(sGMFileName, "r")
  sGMArray = sGMFile.readlines # Reads MLoop File into an array
  sGMFile.close
  
  mBankType = gmBank
  mProgType = gmPatch
  mBankType = mBankType# [..4]
  mProgType = mProgType#[2..4]
  
  #find the GM preset information for the bank and program/patch
  sGMArray.each do |gMLine|
    sGMPatch = gMLine.split(",")[1]
    sGMBank = gMLine.split(",")[0]
    if sGMPatch == mProgType && sGMBank == mBankType
      sMixerPresetArray.push(gMLine) # puts the presets from the soundfont GM file associated with the mixer program/patch requested
    end
  end
  
  return sMixerPresetArray
end
