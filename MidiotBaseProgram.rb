# Sonic Pi Midiot Base Program V0

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
  sampleFile = File.open(sampleFileName, "r")
  sampleArray = sampleFile.readlines # Reads Sample File into an array
  sampleFile.close
  prevSample = " "
  sampleArray.each do |sampleLine|
    currentSample = sampleLine.split(",")[3]
    if currentSample != prevSample
      externalSample = gMPathDir + currentSample + ".wav"
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

def readMidiLoop (mloopDir: " ", mloop: " ", sliceBegin: "1.1.0", sliceEnd: "-1", transpose: 0, loopIt: "N")
  
  rNoteArray = []
  noteFlag = "N"
  mLoopFile = mloopDir + mloop
  f = File.open(mLoopFile, "r")
  rLoopArray = f.readlines # Reads MLoop File into an array
  rNoteArray.push loopIt
  if sliceEnd.to_s.include? "." # has legitimate beat.measure.ticks slice requested
    midiSliceBegin = midiSlice(sliceBegin)
    midiSliceEnd = midiSlice(sliceEnd)
  end
  rLoopArray.each do |element|
    if element[0..4] == "Notes"  # get Notes
      noteFlag = "Y"
    end
    if noteFlag == "Y"
      if element[0..4] != "Notes"  # get Notes
        newNote = element.split(",")[5].to_i + transpose.to_i
        midiStr = element.to_s
        newMLoopLine = midiStr.split(",")[0] + "," + midiStr.split(",")[1] + "," + midiStr.split(",")[2] + "," + midiStr.split(",")[3] + "," + midiStr.split(",")[4] + "," + newNote.to_s + "," + midiStr.split(",")[6]
        if sliceEnd.to_s.include? "-1"
          rNoteArray.push element
        elsif element.split(",")[1].to_i >= midiSliceBegin.to_i
          if element.split(",")[1].to_i <= midiSliceEnd.to_i
            rNoteArray.push newMLoopLine
          end
        end
      end
    end
  end
  f.close
  return rNoteArray
end

def midisynth (synthName=:beep, midiArray=" ", amp: 1.0, amp_slide: 1, pan: 0, pan_slide: 1, attack: -1, decay: -1, sustain: -1, release: -1, attack_level: -1, decay_level: -1, sustain_level: -1, env_curve: -1, slide: -1, pitch: -1)
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

def samplePlayer (i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack=0.01, decay=0.3, sustain=0.5, releaseTime=0, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, panIn, midiFlag)
  
  instrumentPlaying = presetSettings.split(",")[7]
  if midiFlag == "Y"
    sampleRec = sampleArray[midiArray[i].split(",")[5].to_i].to_s # using note number from the midi record as an index get the record from pisf for that note
    noteRelease = midiArray[i].split(",")[4].to_f
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
  if duration.to_s != "N" # not from midiplayer
    
  end
  noteDurationInSecs = noteRelease.to_f / ticksPerMin.to_f * 60 # how many ticks the note plays for divided by ticks in a minute times 60 seconds in a minute
  noteDurationInFrames = sampleRate * noteDurationInSecs # sample rate is frames per second * number of seconds the note is held for
  sustainTime = noteDurationInSecs / sampleTime
  
  if noteDurationInFrames > sampleFrames # stretch the sample
    numOfLoops = (((noteDurationInFrames - sampleFrames) / loopFrames) + 1).floor # you add 1 back in because the loop needs to play for first time through the sample
    synth "sonic-pi-wav_looper", buf: load_sample_at_path(sampleToPlay).id, startLoop: startLoop, endLoop: endLoop, numOfTimes: numOfLoops, amp: amp, rateShift: rateToPlay, lpfFreq: lpfFreqCutoffSonicPi, hpfFreq: hpfFreqCutoffSonicPi, panIn: panIn, attack: attack, decay: decay, sustain: sustain, release: releaseTime
    #synth "sonic-pi-wav_looper", buf: load_sample_at_path(sampleToPlay).id, startLoop: startLoop, endLoop: endLoop, numOfTimes: numOfLoops, amp: amp, rateShift: rateToPlay, panIn: panIn
  else
    if sampleFrames != 0
      sample sampleToPlay, rate: rateToPlay, amp: amp, sustain: noteDurationInSecs, attack: attack, decay: decay, release: releaseTime, lpf: lpfFreqCutoff.to_f, hpf: hpfFreqCutoff.to_f, pan: panIn # play on part of the sample
      #sample sampleToPlay, rate: rateToPlay, amp: amp, release: releaseTime, lpf: lpfFreqCutoff.to_f, pan: panIn # play on part of the sample
    else
      sample sampleToPlay, rate: rateToPlay, amp: amp, lpf: lpfFreqCutoff.to_f, hpf: hpfFreqCutoff.to_f, pan: panIn # cannot play a partial sample because don't know sampleFrames
      #sample sampleToPlay, rate: rateToPlay, amp: amp, lpf: lpfFreqCutoff.to_f, pan: panIn # cannot play a partial sample because don't know sampleFrames
    end
  end
end

def midiSamplePlayer (gmPathDir, midiArray, sampleArray, presetSettings, attack, decay, sustain, releaseTime, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan)
  loopIn = midiArray[0]
  loopLoop = "Y"
  midiArray = midiArray.drop(1)
  numofnotes = midiArray.length
  while loopLoop == "Y"
    numofnotes.times do |i|
      if i.to_i < (numofnotes.to_i - 1)
        msleep = midiArray[i+1].split(",")[2].to_i/120.to_f  #time until next note plays
        msleep = msleep.round(3)
      else
        msleep = 0.0
      end
      samplePlayer i, "N", gmPathDir, sampleArray, midiArray, presetSettings, attack, sustain, decay, releaseTime, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, "Y"
      sleep msleep
    end
    if loopIn == "N"
      loopLoop = "N"
    end
  end
  stop
end

def instrument(midiIn, duration: 1.0, gmBank: "000", gmPatch: "000", gmPathDir: "C:/Users/Michael Sutton/Midiloop/default/", amp: 1.0, attack: 0.01, decay: 0.3, sustain: 0.5, release: 1.0, lpf: 128, hpf: 1, bpm: 60, pan: 0.0)
  
  sMixerPresetArray = buildGMSampleArray(gmPathDir, gmBank, gmPatch)
  presetMixerLineForPatch = sMixerPresetArray[0]
  presetMixerLineForPatchLength = presetMixerLineForPatch.length
  presetSettings = presetMixerLineForPatch[8..presetMixerLineForPatch.length].partition(",").last
  
  sampleToPlay = presetSettings.split(",")[7]
  sampleFileName = gmPathDir + sampleToPlay + ".pisf"
  sampleArray = getSample(sampleFileName, gmPathDir)
  
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
  if midiIn.instance_of? Array
    if midiIn[0].instance_of? String
      midiSamplePlayer gmPathDir, midiIn, sampleArray, presetSettings, attack, decay, sustain, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan
    end
  end
  if midiIn.instance_of? Symbol
    midiArray = []
    midiInStr = midiIn
    samplePlayer midiIn.to_i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack, sustain, decay, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, "N"
  end
  if midiIn.kind_of? Integer
    samplePlayer midiIn.to_i, duration, gmPathDir, sampleArray, midiArray, presetSettings, attack, sustain, decay, release, lpfFreqCutoff, hpfFreqCutoff, amp, bpm, pan, "N"
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
