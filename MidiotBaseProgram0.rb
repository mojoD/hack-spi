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
  
  # spin through array and preload samples
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

def readMidiLoop (mLoopDir, mLoopIn)
  rNoteArray = []
  noteFlag = "N"
  mLoopFile = mLoopDir + mLoopIn
  f = File.open(mLoopFile, "r")
  rLoopArray = f.readlines # Reads MLoop File into an array
  rLoopArray.each do |element|
    if element[0..4] == "Notes"  # get Notes
      noteFlag = "Y"
    end
    if noteFlag == "Y"
      if element[0..4] != "Notes"  # get Notes
        rNoteArray.push element
      end
    end
  end
  f.close
  return rNoteArray
end

def readProgramLoop (mLoopDir, mLoopIn)
  rProgramArray = []
  programFlag = "N"
  mLoopFile = mLoopDir + mLoopIn
  f = File.open(mLoopFile, "r")
  rLoopArray = f.readlines # Reads MLoop File into an array
  rLoopArray.each do |element|
    if element[0..4] == "Notes"
      break
    end
    if element[0..2] == "Con"
      break
    end
    if element[0..2] == "Ins"  # get Midi Patches
      programFlag = "Y"
    end
    if programFlag == "Y"
      if element[0..2] != "Ins"  # get Patches
        rProgramArray.push element
      end
    end
  end
  f.close
  return rProgramArray
end

def midiLoopSynthPlayer (loopName, midiProg, midiArray, midiVolume)
  #use_synth midiProg
  #live_loop loopName do
  numofnotes = midiArray.length
  numofnotes.times do |i|
    noterelease = midiArray[i].split(",")[4].to_f/120
    #play midiArray[i].split(",")[5].to_i, release: noterelease, amp: midiVolume
    sleepStr = midiArray[i].split(",")[2].to_i/120.to_f
    #sleep midiArray[i].split(",")[2].to_i/120.to_f
  end
  #end
end

def midiLoopSamplePlayer (gMPathDir, loopName, midiArray, presetSettings, playMute, stereoMono, velocityAware, effects, amp)
  loopIndex = 0
  sampleToPlay = presetSettings.split(",")[7]
  sampleFileName = gMPathDir + sampleToPlay + ".pisf"
  sampleArray = getSample(sampleFileName, gMPathDir)
  
  if playMute.include? "play"
    live_loop loopName do
      numofnotes = midiArray.length
      numofnotes.times do |i|
        msleep = midiArray[i].split(",")[2].to_i/120.to_f
        msleep = msleep.round(2)
        #if msleep == 0.0
        #  msleep = 0.01
        #end
        instrumentPlaying = presetSettings.split(",")[7]
        #puts "sampleArrayRec: " + sampleArray[midiArray[i].split(",")[5].to_i].to_s # find the sample array record for the note being played
        sampleRec = sampleArray[midiArray[i].split(",")[5].to_i].to_s
        sampleToPlay = gMPathDir.to_s + sampleRec.split(",")[3].to_s + ".wav"
        rateToPlay = sampleRec.split(",")[2]
        noteRelease = midiArray[i].split(",")[4].to_i/120.to_f
        sample sampleToPlay, rate: rateToPlay, release: noteRelease, amp: amp
        #puts "sample " + sampleToPlay.to_s + ", rate: " + rateToPlay.to_s + ", amp: " + amp.to_s
        #puts "sleep " + msleep.to_s
        sleep msleep
      end
    end
  end
end

def buildMidiArrays (gMPathDir, mLoopDir, mProgType, sMixerPresetArray, mMixer)
  i = 1
  Dir.foreach(mLoopDir) do |mloops|
    next if mloops == "." or mloops == ".." or mloops == "drums" or mloops == "header.txt" or mloops == "logfile.txt" or mloops == "drumkit.txt" or mloops == "sequencer.txt"
    midiArray = []
    midiArray = readMidiLoop(mLoopDir, mloops)
    #all to do with building presets
    programArray = []
    programArray = readProgramLoop(mLoopDir, mloops)
    patchToFind = " "
    playMute = " "
    stereoMono = " "
    velocityAware = " "
    effects = " "
    amp = " "
    presetSettings = " "
    mLoopDir = mLoopDir
    programArray.each_slice(4) do |patch|
      puts "patch: " + patch.to_s
      patchToFind = patch.to_s.split(",")[2]
    end
    patchToFindStr = patchToFind.to_i
    if patchToFind.to_i < 10
      patchToFindStr = "00" + patchToFind.to_i.to_s
    elsif patchToFind.to_i < 100
      patchToFindStr = "0" + patchToFind.to_i.to_s
    end
    presetMixerLineForPatch = " "
    
    # When building the midi arrays find the patch information in terms of which and how many samples to play
    sMixerPresetArray.each do |presetMixerLine|  # this is an array with crlf
      patchInPresetMixerLine = presetMixerLine.split(",")[1]
      bankInPresetMixerLine = presetMixerLine.split(",")[0]
      if bankInPresetMixerLine.to_s == "128"
        bankToFindStr = "128"
        patchToFindStr = patchInPresetMixerLine.to_s
        patchToFind = patchToFindStr.to_i
      else
        bankToFindStr = "000" # assume on non drums it is bank 0 for the instruments
      end
      playMute = "mute"
      stereoMono = "mono"
      velocityAware = "novelocity"
      effects = "Effects"
      
      if patchToFindStr == patchInPresetMixerLine && bankToFindStr == bankInPresetMixerLine
        presetMixerLineForPatch = presetMixerLine
        presetMixerLineForPatchLength = presetMixerLineForPatch.length
        presetSettings = presetMixerLineForPatch[8..presetMixerLineForPatch.length].partition(",").last
        i=0
        breakloop = "N"
        8.times do
          instrumentToFind = presetSettings.split(",")[i*8+8]
          # check to see mixer options
          # find matching mixer record
          mMixer.each_slice(10) do |mLine|
            currentPatch = mLine.to_s.split(",")[3][1..-1] # trim leading character
            if currentPatch.to_s == patchToFind.to_s # found mixer entry associated with current preset
              amp = mLine.to_s.split(",")[5][1..-1]
              playMute = mLine.to_s.split(",")[6][1..-1]
              stereoMono = mLine.to_s.split(",")[7][1..-1]
              velocityAware = mLine.to_s.split(",")[8][1..-1]
              effects = mLine.to_s.split(",")[9][1..-1]
              effects = effects[0..effects.length-1][1..-1]
              breakloop == "Y"
              break
            end
          end
          break if breakloop == "Y"
          i += 1
        end
        break
      end
    end
    
    trackNum = mloops[6..7]
    patch = i*3-2
    if mProgType == "sequencer"
      loopName = ":sampleloop_Channel" + trackNum.to_s
      midiLoopSamplePlayer gMPathDir, loopName, midiArray, presetSettings, playMute, stereoMono, velocityAware, effects, amp
    else
      loopName = ":synthloop_Channel" + trackNum.to_s
      midiProg = mPatchArray[patch]
      midiVolume = mPatchArray[patch+1]
      midiLoopSynthPlayer loopName, midiProg, midiArray, midiVolume
    end
    i += 1
  end
end

def buildGMSampleArray(gMDirIn, mMixer)
  sGMArray = []
  sMixerPresetArray = []
  sampleFlag = "N"
  sGMFileName = gMDirIn + ".presets.info"
  sGMFile = File.open(sGMFileName, "r")
  sGMArray = sGMFile.readlines # Reads MLoop File into an array
  sGMFile.close
  
  i = 1
  # mMixer.each do |mLine|
  mMixer.each_slice(10) do |mLine|
    currentPatch = mLine.to_s.split(",")[0]
    mBankType = mLine.to_s.split(",")[2]
    mProgType = mLine.to_s.split(",")[3]
    
    #find the GM preset information for the bank and program/patch
    mBankTypeStr = mBankType.to_i.to_s
    if mBankType.to_i < 10
      mBankTypeStr = "00" + mBankType.to_i.to_s
    elsif mBankType.to_i < 100
      mBankTypeStr = "0" + mBankType.to_i.to_s
    end
    mProgTypeStr = mProgType.to_s
    if mProgType.to_i < 10
      mProgTypeStr = "00" + mProgType.to_i.to_s
    elsif mProgType.to_i < 100
      mProgTypeStr = "0" + mProgType.to_i.to_s
    end
    sGMArray.each do |gMLine|
      sGMPatch = gMLine.split(",")[1]
      sGMBank = gMLine.split(",")[0]
      if sGMPatch == mProgTypeStr && sGMBank == mBankTypeStr
        sMixerPresetArray.push(gMLine) # puts the presets from the soundfont GM file associated with the mixer program/patch requested
      end
      #end
    end
    i += 1
  end
  return sMixerPresetArray
end
