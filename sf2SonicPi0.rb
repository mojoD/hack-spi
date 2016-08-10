#! /usr/bin/env ruby 
# 
# usage: sf2SonicPi0.rb -options [SoundFontFile] [OutputDirectory] 
# 
# This program reads in a soundfont file that has sound font information in it.  It runs a program called sf2comp.exe which decompiles a soundfont file and puts into an structured file that is human readable.
# This program takes this human readable soundfont file and creates two types of files.
#
# Preset files:
# The first type file is the preset file.  The preset file is the information about the 127 midi instruments in the soundfont file, as well as, the drum kits contained there too. 
# Each midi instrument is a unique combination of bank, program, preset instrument name, low/high key ranges, low/high velocity ranges and Sonic Pi panning/detune parameters (stereo settings) and Sonic Pi Frequency Cutoff info (velocity related) 
# For example, the soundfont file for bank 0, program 0 is for a Grand Piano midi instrument.  This grand piano contains 8 unique combinations of the above parameters.
#   bank,   program,    low key,    high key,   low velocity,   high velocity,  cutoff frequency,   pan,        fineTune,   Instrument           
#   000,    000,        0,          127,        0,              46,             126.83622,          125.06404,  -0.00775,   GrandPiano
#   000,    000,        0,          127,        0,              46,             126.83622,          1.9379,     0.00969,    GrandPiano
#   000,    000,        0,          127,        47,             71,             128.60328,          125.06404,  -0.00775,   GrandPiano
#   000,    000,        0,          127,        47,             71,             128.60328,          1.9379,     0.00969,    GrandPiano
#   000,    000,        0,          127,        72,             98,             129.76866,          125.06404,  -0.00775,   GrandPiano
#   000,    000,        0,          127,        72,             98,             129.76866,          1.9379,     0.00969,    GrandPiano
#   000,    000,        0,          127,        99,             127,            0,                  125.06404,  -0.00775,   GrandPiano
#   000,    000,        0,          127,        99,             127,            0,                  1.9379,     0.00969,    GrandPiano
#
# Taking a look at the first combination
# - the bank is 000 and the program is 000.  Most soundfont file will have only two banks.  000 for instruments and 128 for drum kits.  The program will be different for each instrument.  For example, 000 is Acoustic Grand Piano and 105 is Banjo.
# - it is valid for the key/note range of 0-127 which is the full range of midi notes that have been played with a velocity range of betwee 0 - 46 (played rather softly).  
# - the cutoff frequency is 126.83622 which you will notice is the lowest number in the cutoff frequency that means because the note velocity is the softest the frequency cutoff is the lowest meaning that it will sound mellower than the harder velocity notes 
# - the pan is 125.06404 which is hard right
# - the finetune or detune is -0.00775 from the rate calculation in Sonic Pi meaning that the far right pan of the note is detuned slightly flatter.  Far left pans will be tuned slightly sharper.  Isn't Physics cool!
# - all the presets use the same instrument.  The GrandPiano Instrument.  This is not always the case for a given preset, but, generally is.  For example, based on the velocity of the note being played it might select a different instrument.
#
# Instrument Files:
# These files with the extension (.pisf) for pi soundfont are contained in a directory that the user passes as an argument (OutputDirectory as identified in the usage that is shown at the top of this file)
#
# Each one of these .pisf pi soundfont files have multiple comma delimited records with the following format:
#   Instrument Name, midi note, rate modifier, sample name, pointer to next sample if multisample instrument
# for example ( GrandPiano,62,1.12246,BrightPiano C4,0 ) 
# is a record that is for L
# - the instrument name is GrandPiano, 
# - midinote 62 which is D above middle C.  For all non-drum instruments (meaning anything that is has a bank number < 129) the full 128 possible midinotes that could be found in a midi music file are in this .pisf pi soundfont file. 
# - 1.12246 which is used by the sonic pi rate function to raise the pitch of the sample for C4 to D4,
# - it is using a sample named BrightPiano C4.  The samples are all contained in the samples folder as separate files.
#
# The next portion of the pisf record will have information that is gotten from the wav file to be played.  The information has to do with how to stretch the note using cue/loop points in the meta data in .wav file.
# Added to the pisf record from the wav file are:
# - sample rate in frames (i.e. 44100)
# - sample size in frames 
# - sample duration in seconds
# - frame of the start of the duration stretch loop
# - frame of the end of the duration stretch loop
# - loop duration in frames (loopend - loopstart +1)
# - midi note from wav file that the sample was based on
#
# The last item of the pisf record is gotten from the decompiled soundfont file 
# - it has a doesn't have a pointer to another sample (i.e. pointer is 0).  If this was a multisample note, then this value would be the something above 127 like 190 for example.  That would mean you would go to position 190 in the array to find the next sample to play.   
# Record 190 might look like this ( ElectricGrandPiano,62,1.12246,ElectricGrandPiano,EP 2 C4,0 )
# - it is using a different sample (EP 2 C4 versus BrightPiano C4)
# - this means that the GrandPiano would be a combination of both a BrightPiano and an Electric Piano set of samples if it had been multi-sample.
#
# In summary, the pisf record layout is:
# Instrument Name, midiNote, rate,    sample to play, sample rate in frames, sample size in frames, sample size in secs, loop start frame, loop end frame, loop druatin in frames, base midi note, pointer to multisample
# GrandPiano,      74,       1.12246, BrightPiano C5, 44100,                 33679,                 0.7637,              33426,            33675,          249,                     72,            0
#
# Outputs from this program are stored in the directory that is passed as the second argument when calling this program.
# - .preset.info file which has all the presest with bank, program and instrument information used to create the track mixer in Sonic Pi
# - *.pisf files for each instrument in the soundfont file.  This contains the samples and rate offsets to use when playing samples in Sonic Pi using the instrument.
# - *.wav files which are the files with the actual samples in them
# - log.txt which is the log file used for debugging
#
#
# How will Sonic Pi consume this information?
#  
# When a midi file is processed for sonic pi using midi2sonicpi.exe 
# - a ruby program is generated that 
# pass bank, program, note & velocity to function
# it would go the matching preset array for the given bank and go to the index in the array matching the program
# it would then look at each lk1, hk1 (key range), lv1, hv1 (velocity range), if in key & velocity range it would set fc, pan, ft variables and get the note information from correct instrument array
#
# example with preset and note arrays above for: note = 62, velocity = 50, bank = 0, program = 1, duraton = 60 
# if would look in the bank 0 presetArray[1] (i.e. for program 0 info).  
# it would check the first key range is note value of 62 with in the key range 0.127, yes. is velocity value 50 within the velocity range 0..44, no.  So, it would go to the second key/velocity range on the record
# it would check the second key range is note value of 62 with in the key range 0.127, yes. is velocity value 50 within the velocity range 0..44, no.  So, it would go to the third key/velocity range on the record
# it would check the third key range is note value of 62 with in the key range 0.127, yes. is velocity value 50 within the velocity range 45..60, yes.  A match.
#   - it would set the variable fc (frequency cutoff) to 62750, the variable pan to 64536 (hard right) and the variable ft (fineTune or detune) to 65531 from the corresponding elements for the matched key/velocity range
#   - it would go the instrument array named in the third key/velocity range data just matched which is BrightPiano.  BrightPianoArray [62] - index in the array is the note # since all the notes are in the array (0-127)
#   - it would set the sample variable to BrightPiano C4, the variable rateAdjust to 1.1224632155504721
#   - it now build the sample record as sample BrightPiano_C4, pan: 64536, rate: 1.1224632155504721-(65536-65531)/65536, lpf: 62750 / 65535 * 131
#   - it would build the sleep record as sleep (duration / 120).  duration of the note in miditicks by 120 ticks per beat.  60 / 120 = 0.5 which would be .5 of a 4 beat measure or in other words an eighth note. 
#   - the rate is calculated as the rateoffset (getting from C4 to D4) of 1.1224632155504721 and then calculating the detune by with will be negative because it is a flatting (i.e. the value 65531 > 32768).  
#        - detune would be 65536 - 65531 = 5.  5 / 65535 = 0.0000763.  1.1224632155504721 - 0.0000763 = 1.12238692044099
#   - the lpf or low pass filter is set to the value in sonic pi that is a range of 0..131 by taking the Frequency cutoff (fc) and dividing it by 65535 (since in Midi the Fc range is 0..65535)
#        - 62750 / 65535  = .957503624  which is multiplied by the top of the sonic pi range (131) .957503624 * 131 = 125.432974746319
#   - so the resulting sample and sleep statements would look like:
#   sample BrightPiano_C4, pan: 64536, rate: 1.12246, lpf: 125.432974746319
#   sleep 0.5
#
#

$LOAD_PATH[0, 0] = File.join(File.dirname(__FILE__), '..', 'lib') 

require 'FileUtils'


directoryname = ARGV[1]
FileUtils.rm_rf(directoryname)
Dir.mkdir(directoryname) unless File.exists?(directoryname) 

cmdString = "start /wait sf2comp.exe d " + ARGV[0] + " ./" + directoryname 
system(cmdString)
puts "cmdString: " + cmdString.to_s

#read everything into an array to make processing faster 
puts "Started"
inFileArg = ARGV[0]
inFileName = inFileArg.split(".")[0]
inFile = directoryname + "/" + inFileName + ".txt"
puts "inFile: " + inFile.to_s
puts "********************  Please Wait While Processing Finishes ***********************"  
f = File.open(inFile, 'r') 
sfInArray = f.readlines
f.close

filename = directoryname + "/.log.txt"
logfile = File.new(filename,"w+")

def findSampleBaseKey (sampleName, sampleArray)
    sampleArrayPos = 0
    sampleBaseKey = 0
    sampleArray.each do |sampleLine|
        if sampleLine == sampleName
            sampleBaseKey = sampleArray[sampleArrayPos+1]
            break
        end
        sampleArrayPos += 1
    end
    return sampleBaseKey
end

def noteOffset (baseNote, noteIn)
    # Halper Arrays
    note2FreqArray = [0,8.176,1,8.662,2,9.177,3,9.773,4,10.301,5,10.913,6,11.562,7,12.250,8,12.978,9,13.75,\
                     10,14.567,11,15.434,12,16.351,13,17.324,14,18.354,15,19.445,16,20.601,17,21.827,18,23.124,19,24.499,\
                     20,25.956,21,27.500,22,29.135,23,30.868,24,32.703,25,34.648,26,36.708,27,38.891,28,41.203,29,43.654,\
                     30,46.249,31,48.999,32,51.913,33,55.000,34,58.270,35,61.735,36,65.406,37,69.296,38,73.416,39,77.782,\
                     40,82.407,41,87.307,42,92.499,43,97.999,44,103.826,45,110,46,116.541,47,123.471,48,130.813,49,138.591,\
                     50,146.832,51,155.563,52,164.814,53,174.614,54,184.997,55,195.998,56,207.652,57,220,58,233.082,59,246.942,\
                     60,261.626,61,277.183,62,293.665,63,311.127,64,329.628,65,349.228,66,369.994,67,391.995,68,415.305,69,440,\
                     70,466.164,71,493.883,72,523.251,73,554.365,74,587.33,75,622.254,76,659.255,77,698.456,78,739.989,79,783.991,\
                     80,830.609,81,880.000,82,932.328,83,987.767,84,1046.502,85,1108.731,86,1174.659,87,1244.508,88,1318.51,89,1396.913,\
                     90,1479.978,91,1567.982,92,1661.219,93,1760,94,1864.655,95,1975.533,96,2093.005,97,2217.461,98,2349.318,99,2489.016,\
                     100,2637.021,101,2793.826,102,2959.955,103,3135.964,104,3322.438,105,3520,106,3729.31,107,3951.066,108,4186.009,109,4434.922,\
                     110,4698.636,111,4978.032,112,5274.042,113,5587.652,114,5919.91,115,6271.928,116,6644.876,117,7040,118,7458.62,119,7902.132,\
                     120,8372.018,121,8869.844,122,9397.272,123,9956.064,124,10548.084,125,11175.304,126,11839.82,127,12543.856,128,13289.752,129,14080]
    noteRate = note2FreqArray[noteIn.to_i*2+1].to_f / note2FreqArray[baseNote.to_i*2+1].to_f
    return noteRate            
end

def fineTuneAdjust (fineTuneFloat)
    if fineTuneFloat > 63.0
        fineTuneFloat2 = fineTuneFloat - 127
        fineTune = fineTuneFloat2.round(5)
    else
        fineTune = fineTuneFloat.round(5)
    end
    return fineTune
end

def readWav (wavFile, overridingRootKey)
    puts "wavfile: " + wavFile.to_s
    puts "overridingRootKey: " + overridingRootKey.to_s
    s = File.binread(wavFile)
    if s.include? "smpl"
        smplpos = s.index("smpl") # returns the byte where the end of smpl is
        #puts "found Sample @ " + smplpos.to_s
        midinote = s[smplpos.to_i+20..smplpos.to_i+23]
        midinote = midinote.reverse
        midinote = midinote.unpack("H2" * midinote.size)
        midinote8 = midinote[3][1].to_i(16)
        midinote7 = midinote[3][0].to_i(16)
        midinote = midinote8 + midinote7 * 16
        #puts "midinote: " + midinote.to_s

        sampleloops = s[smplpos.to_i+36..smplpos.to_i+39]
        sampleloops = sampleloops.reverse
        sampleloops = sampleloops.unpack("H2" * sampleloops.size)
        sampleloops8 = sampleloops[3][1].to_i(16)
        sampleloops7 = sampleloops[3][0].to_i(16)
        sampleloops = sampleloops8 + sampleloops7 * 16      
        #puts "sampleloops: " + sampleloops.to_s

        loopstart = s[smplpos.to_i+52..smplpos.to_i+55]
        loopstart = loopstart.reverse
        loopstart = loopstart.unpack("H2" * loopstart.size)
        loopstart8 = loopstart[3][1].to_i(16)
        loopstart7 = loopstart[3][0].to_i(16)
        loopstart6 = loopstart[2][1].to_i(16)
        loopstart5 = loopstart[2][0].to_i(16)   
        loopstart4 = loopstart[1][1].to_i(16)
        loopstart3 = loopstart[1][0].to_i(16)
        loopstart2 = loopstart[0][1].to_i(16)
        loopstart1 = loopstart[0][0].to_i(16)
        loopstart = loopstart8 + loopstart7 * 16 + loopstart6 * 16 * 16 + loopstart5 * 16 * 16 * 16 + loopstart4 * 16 * 16 * 16 * 16 + loopstart3 * 16 * 16 * 16 * 16 * 16 + loopstart2 * 16 * 16 * 16 * 16 * 16 * 16 + loopstart1 * 16 * 16 * 16 * 16 * 16 * 16 * 16
        #puts "loopstart: " + loopstart.to_s

        loopend = s[smplpos.to_i+56..smplpos.to_i+59]
        loopend = loopend.reverse
        loopend = loopend.unpack("H2" * loopend.size)
        loopend8 = loopend[3][1].to_i(16)
        loopend7 = loopend[3][0].to_i(16)
        loopend6 = loopend[2][1].to_i(16)
        loopend5 = loopend[2][0].to_i(16)   
        loopend4 = loopend[1][1].to_i(16)
        loopend3 = loopend[1][0].to_i(16)
        loopend2 = loopend[0][1].to_i(16)
        loopend1 = loopend[0][0].to_i(16)
        loopend = loopend8 + loopend7 * 16 + loopend6 * 16 * 16 + loopend5 * 16 * 16 * 16 + loopend4 * 16 * 16 * 16 * 16 + loopend3 * 16 * 16 * 16 * 16 * 16 + loopend2 * 16 * 16 * 16 * 16 * 16 * 16 + loopend1 * 16 * 16 * 16 * 16 * 16 * 16 * 16
        #puts "loopend: " + loopend.to_s
        loopduration = loopend.to_i - loopstart.to_i
        #puts "loopduration: " + loopduration.to_s
    end
    if s.include? "WAVE"
        wavepos = s.index("WAVE")
        samplesize = s[wavepos+32..wavepos+35]
        samplesize = samplesize.reverse
        samplesize = samplesize.unpack("H2" * samplesize.size)
        #puts "samplesize: " + samplesize.to_s
        samplesize8 = samplesize[3][1].to_i(16)
        samplesize7 = samplesize[3][0].to_i(16)
        samplesize6 = samplesize[2][1].to_i(16)
        samplesize5 = samplesize[2][0].to_i(16)
        samplesize4 = samplesize[1][1].to_i(16)
        samplesize3 = samplesize[1][0].to_i(16)
        samplesize2 = samplesize[0][1].to_i(16)
        samplesize1 = samplesize[0][0].to_i(16)
        samplesize = samplesize8 + samplesize7 * 16 + samplesize6 * 16 * 16 + samplesize5 * 16 * 16 * 16 + samplesize4 * 16 * 16 * 16 * 16 + samplesize3 * 16 * 16 * 16 * 16 * 16 + samplesize2 * 16 * 16 * 16 * 16 * 16 * 16 + samplesize1 * 16 * 16 * 16 * 16 * 16 * 16 * 16
        samplesize = samplesize / 2
        #puts "samplesize: " + samplesize.to_s

        samplerate = s[wavepos+16..wavepos+19]
        samplerate = samplerate.reverse
        samplerate = samplerate.unpack("H2" * samplerate.size)
        #puts "samplerate: " + samplerate.to_s
        samplerate8 = samplerate[3][1].to_i(16)
        samplerate7 = samplerate[3][0].to_i(16)
        samplerate6 = samplerate[2][1].to_i(16)
        samplerate5 = samplerate[2][0].to_i(16)
        samplerate4 = samplerate[1][1].to_i(16)
        samplerate3 = samplerate[1][0].to_i(16)
        samplerate2 = samplerate[0][1].to_i(16)
        samplerate1 = samplerate[0][0].to_i(16)
        samplerate = samplerate8 + samplerate7 * 16 + samplerate6 * 16 * 16 + samplerate5 * 16 * 16 * 16 + samplerate4 * 16 * 16 * 16 * 16 + samplerate3 * 16 * 16 * 16 * 16 * 16 + samplerate2 * 16 * 16 * 16 * 16 * 16 * 16 + samplerate1 * 16 * 16 * 16 * 16 * 16 * 16 * 16
        #puts "samplerate: " + samplerate.to_s

        sampleduration = samplesize.to_f / samplerate.to_f
        sampleduration = sampleduration.round(4)
        #puts "sampleduration: " + sampleduration.to_s
    end
    if overridingRootKey.to_s != "0"

        puts "found an overridingRootKey"
        midinote = overridingRootKey.to_s[0..overridingRootKey.length-2]
    end
        pisfinsert = samplerate.to_s + "," + samplesize.to_s + "," + sampleduration.to_s + "," + loopstart.to_s + "," + loopend.to_s + "," + loopduration.to_s + "," + midinote.to_s + ","
        puts "pisfinsert: " + pisfinsert.to_s
        return pisfinsert
end



# options (stero samples supported or not, multiple samples based on velocity or not, multisamples for one key (excluding stereo))
stereoOption = "N"
velocityOption = "N"
multisampleOption = "N"

presetArray = []
instrumentArray = []
sampleArray = []

#Break into a Preset and 
sfSection = "None"
sfInArray.each do |sfLineIn|
    #puts sfLineIn.to_s
    if sfLineIn[0..8] == "[Samples]"
    	sfSection = "Samples"
    end
    if sfLineIn[0..12] == "[Instruments]"
    	sfSection = "Instruments"
    end    	
    if sfLineIn[0..8] == "[Presets]"
    	sfSection =  "Presets"
    end

    if sfLineIn[0..5] == "[Info]"
    	sfSection = "Info"
    end
    #Build an array with all the preset settings in it
    if sfSection == "Presets"
        if sfLineIn.length > 1
            presetArray.push(sfLineIn)
            #logfile.puts "preset line: " + sfLineIn.to_s
        end
    end
    # Build an array with all the instrument settings from the soundfont file
    if sfSection == "Instruments"   
        if sfLineIn.length > 1
            instrumentArray.push(sfLineIn.to_s)
            #logfile.puts "instrumenline: " + sfLineIn.to_s
        end
    end
    # Build an array with all the sample settings from the soundfont file
    if sfSection == "Samples"   
        if sfLineIn.length > 1
            if sfLineIn.include? "SampleName"
                sampleInName = sfLineIn.partition("=").last
                sampleArray.push(sampleInName)
                #logfile.puts sampleInName.to_s
            end
            if sfLineIn.include? "Key"
                sampleInKey = sfLineIn.partition("=").last
                sampleArray.push(sampleInKey)
                #logfile.puts sampleInKey.to_s
            end 
        end
    end
end

#sampleArray.each do |sline|
#    logfile.puts "sampleArray: " + sline.to_s   
#end

#read Presets into an Array
presetNum = 0
lowKey = 0
highKey = 0
bankName = ""
programName = ""
presetName = ""
panName = ""
lowVelocityName = ""
highVelocityName = ""

#
instrumentCntr = -1
presetNameArray = []
presetInstrumentArray = []
lowKeyArray = []
highKeyArray = []
lowVelocityArray = []
highVelocityArray = []
panArray = []
initialFilterFcArray = []
fineTuneArray = []
presetRecArray = []
bankNameArray = []
programNameArray = []
presetInstrumentName = "No Instrument"
lowKeyName = "0"
highKeyName = "127"
lowVelocityName = "0"
highVelocityName = "127"
initialFilterFcName = "0"
panName = "0"
fineTuneName = "0"

presetArray.each do |presetLine|
    if presetLine.include? "PresetName"
        presetName = presetLine.partition("=").last
    end
    if presetLine.include? "Instrument"
        presetInstrumentName = presetLine.partition("=").last
        instrumentCntr += 1
        presetInstrumentRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName[0..presetInstrumentName.length]
        presetInstrumentArray.push(presetInstrumentRec)
    end
    if presetLine.include? "Bank"
        bankName = presetLine.partition("=").last
        if bankName.to_i < 10 
            bankName = "00" + bankName
        elsif bankName.to_i < 100
            bankName = "0" + bankName
        end
        bankNameRec = presetName.to_s[0..presetName.length-2] + "," + bankName.to_s
        bankNameArray.push(bankNameRec)
    end
    if presetLine.include? "Program"
        programName = presetLine.partition("=").last
        if programName.to_i < 10
            programName = "00" + programName
        elsif programName.to_i < 100
            programName = "0" + programName
        end
        programNameRec = presetName.to_s[0..presetName.length-2] + "," + programName.to_s       
        programNameArray.push(programNameRec)
        presetNameRec = presetName.to_s[0..presetName.length-2] + "," + bankName.to_s[0..bankName.length-2] + "," + programName.to_s
        presetNameArray.push(presetNameRec)
    end
    if presetLine.include? "L_LowKey"
        lowKeyName = presetLine.partition("=").last
        lowKeyRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + lowKeyName.to_s
        lowKeyArray.push(lowKeyRec)
    end
    if presetLine.include? "L_HighKey"
        highKeyName = presetLine.partition("=").last        
        highKeyRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + highKeyName.to_s
        highKeyArray.push(highKeyRec)
    end    
    if presetLine.include? "L_LowVelocity"
        lowVelocityName = presetLine.partition("=").last
        lowVelocityRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + lowVelocityName.to_s
        lowVelocityArray.push(lowVelocityRec)
    end
    if presetLine.include? "L_HighVelocity"
        highVelocityName = presetLine.partition("=").last      
        highVelocityRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + highVelocityName.to_s
        highVelocityArray.push(highVelocityRec)
    end
    if presetLine.include? "L_initialFilterFc"
        initialFilterFcName = presetLine.partition("=").last     
        initialFilterFcRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + initialFilterFcName.to_s
        initialFilterFcArray.push(initialFilterFcRec)
    end
    if presetLine.include? "L_pan"
        panName = presetLine.partition("=").last  
        panRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + panName.to_s
        panArray.push(panRec)
    end    
    if presetLine.include? "L_fineTune"
        fineTuneName = presetLine.partition("=").last        
        fineTuneRec = presetName.to_s[0..presetName.length-2] + "," + presetInstrumentName.to_s[0..presetInstrumentName.length-2] + "," + fineTuneName.to_s
        fineTuneArray.push(fineTuneRec)
    end

    #puts presetLine.to_s
    sampleName = ""
    instrumentName = ""
    noterate = 0
    processInstrument = "N"

end

# print out previous arrays
#logfile.puts "**************************************presetNameArray"
#presetNameArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************bankNameArray"
#bankNameArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************programNameArray"
#programNameArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************presetInstrumentrray"
#presetInstrumentArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************lowKeyArray"
#lowKeyArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************end lowKeyArray"
#logfile.puts "**************************************highKeyArray"
#highKeyArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************lowVelocityArray"
#lowVelocityArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "**************************************highVelocityArray"
#highVelocityArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "****************************************initialFilterFcArray"
#initialFilterFcArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "*****************************************panArray"
#panArray.each do |line|
#    logfile.puts line
#end
#logfile.puts "***********************************************fineTuneArray"
#fineTuneArray.each do |line|
#    logfile.puts line
#end

# Write out Preset Arrays
presetInstrumentOutArray = []
lowKeyPresetName = ""
lowKeyInstrumentName = ""
presetName = ""
instrumentName = ""
instrument1 = "999"
instrument2 = "999"
instrument3 = "999"
instrument4 = "999"
instrument5 = "999"
instrument6 = "999"
instrument7 = "999"
instrument8 = "999"
instrument9 = "999"
instrument10 = "999"
lowKeyCntr = 0    

# build record
presetNameArray.each do |presetRec|
    presetInstrumentRec = ""
    presetRecName = presetRec.split(",")[0]
    presetBank = presetRec.split(",")[1]
    presetProgram = presetRec.split(",")[2]
    #puts "presetInstrumentArray length: " + presetInstrumentArray.length.to_s
    presetInstrumentCntr = 0
    #lowKeyCntr = 0
    highKeyCntr = 0
    lowVelocityCntr = 0
    highVelocityCntr = 0
    initialFilterFcCntr = 0
    panCntr = 0
    fineTuneCntr = 0
    presetInstrumentArray.each do |presetInstrument|
        presetName = presetInstrument.split(",")[0]
        instrumentName = presetInstrument.split(",")[1].chop
        if presetName == presetRecName # instruments for current preset
            lowKey = "0"
            lowKeyArray.each do |lowKeyRec|
                lowKeyPresetName = lowKeyRec.split(",")[0]
                lowKeyInstrumentName = lowKeyRec.split(",")[1]               
                if lowKeyPresetName == presetName
                    if presetInstrumentCntr == lowKeyCntr                    
                        if lowKeyInstrumentName.to_s == instrumentName.to_s                         
                            lowKey = lowKeyRec.split(",")[2].chop
                        end
                    end
                    lowKeyCntr += 1
                end    
            end

            highKey = "0"
            highKeyArray.each do |highKeyRec|
                highKeyPresetName = highKeyRec.split(",")[0]
                highKeyInstrumentName = highKeyRec.split(",")[1]
                if highKeyPresetName == presetName
                    if highKeyInstrumentName.to_s == instrumentName.to_s
                        if presetInstrumentCntr == highKeyCntr
                            highKey = highKeyRec.split(",")[2].chop
                        end
                    end
                    highKeyCntr += 1                    
                end    
            end

            lowVelocity = "0"
            lowVelocityArray.each do |lowVelocityRec|
                lowVelocityPresetName = lowVelocityRec.split(",")[0]
                lowVelocityInstrumentName = lowVelocityRec.split(",")[1]
                if lowVelocityPresetName == presetName
                    if lowVelocityInstrumentName.to_s == instrumentName.to_s                        
                        if presetInstrumentCntr == lowVelocityCntr
                            lowVelocity = lowVelocityRec.split(",")[2].chop
                        end
                    end
                    lowVelocityCntr += 1                    
                end    
            end

            highVelocity = "0"
            highVelocityArray.each do |highVelocityRec|
                highVelocityPresetName = highVelocityRec.split(",")[0]
                highVelocityInstrumentName = highVelocityRec.split(",")[1]
                if highVelocityPresetName == presetName
                    if highVelocityInstrumentName.to_s == instrumentName.to_s
                        if presetInstrumentCntr == highVelocityCntr
                            highVelocity = highVelocityRec.split(",")[2].chop
                        end
                    end
                    highVelocityCntr += 1                    
                end    
            end

            initialFilterFc = "0"
            initialFilterFcArray.each do |initialFilterFcRec|
                initialFilterFcPresetName = initialFilterFcRec.split(",")[0]
                initialFilterFcInstrumentName = initialFilterFcRec.split(",")[1]
                if initialFilterFcPresetName.to_s == presetName.to_s
                    if initialFilterFcInstrumentName == instrumentName
                        if presetInstrumentCntr == initialFilterFcCntr
                            initialFilterFc = initialFilterFcRec.split(",")[2].chop
                            initialFilterFcFloat = initialFilterFc.to_f
                            initialFilterFcFloat = (initialFilterFcFloat / 65535) * 131  # adjusted from midi settings to sonic pi settings
                            initialFilterFc = initialFilterFcFloat.round(5)
                        end
                    end
                    initialFilterFcCntr += 1                    
                end    
            end

            pan = "0"
            panArray.each do |panRec|
                panPresetName = panRec.split(",")[0]
                panInstrumentName = panRec.split(",")[1]
                if panPresetName == presetName
                    if panInstrumentName.to_s == instrumentName.to_s
                        if presetInstrumentCntr == panCntr
                            pan = panRec.split(",")[2].chop
                            panFloat = pan.to_f
                            panFloat = panFloat / 65535 * 127 # adjusted from midi settings to sonic pi settings
                            pan = panFloat.round(5)
                        end
                    end
                    panCntr += 1                    
                end    
            end

            fineTune = "0"
            fineTuneArray.each do |fineTuneRec|
                fineTunePresetName = fineTuneRec.split(",")[0]
                fineTuneInstrumentName = fineTuneRec.split(",")[1]
                if fineTunePresetName.to_s == presetName.to_s
                    if fineTuneInstrumentName == instrumentName
                        if presetInstrumentCntr == fineTuneCntr
                            fineTune = fineTuneRec.split(",")[2].chop
                            fineTuneFloat = fineTune.to_f                            
                            fineTuneFloat = fineTuneFloat / 65535 * 127  # adjusted from midi settings to sonic pi settings
                            fineTune = fineTuneAdjust(fineTuneFloat)                     
                        end
                    end
                    fineTuneCntr += 1                    
                end    
            end

            # Build Preset Instrument Rec 
            presetInstrumentRec = lowKey.to_s + "," + highKey.to_s + "," + lowVelocity.to_s + "," + highVelocity.to_s + "," + initialFilterFc.to_s + "," + pan.to_s + "," + fineTune.to_s + "," + instrumentName.to_s
            presetInstrumentOutArray.push(presetInstrumentRec)
            presetInstrumentCntr += 1
            lowKeyCntr = 0
            highKeyCntr = 0
            lowVelocityCntr = 0
            highVelocityCntr = 0
            initialFilterFcCntr = 0
            panCntr = 0
            fineTuneCntr = 0
            #if presetName.include? "PopDrums"
            #    logfile.puts presetInstrumentRec
            #end
        end    
    end
    # Build output rec
    instrumentCount = presetInstrumentOutArray.length
    if instrumentCount >= 1
        instrument1 = presetInstrumentOutArray[0]
    end
    if instrumentCount >= 2
        instrument2 = presetInstrumentOutArray[1]
    end
    if instrumentCount >= 3
        instrument3 = presetInstrumentOutArray[2]
    end
    if instrumentCount >= 4
        instrument4 = presetInstrumentOutArray[3]
    end
    if instrumentCount >= 5
        instrument5 = presetInstrumentOutArray[4]
    end
    if instrumentCount >= 6
        instrument6 = presetInstrumentOutArray[5]
    end
    if instrumentCount >= 7
        instrument7 = presetInstrumentOutArray[6]
    end
    if instrumentCount >= 8
        instrument8 = presetInstrumentOutArray[7]
    end
    if instrumentCount >= 9
        instrument9 = presetInstrumentOutArray[8]
    end
    if instrumentCount == 10
        instrument10 = presetInstrumentOutArray[9]
    end               
    presetOutRec = presetBank.to_s + "," + presetProgram.to_s[0..presetProgram.length-2] + "," + presetRecName.to_s + "," + instrument1.to_s + "," + instrument2.to_s + "," + instrument3.to_s + "," + instrument4.to_s + "," + instrument5.to_s + "," + instrument6.to_s + "," + instrument7.to_s + "," + instrument8.to_s + "," + instrument9.to_s + "," + instrument10.to_s 
    presetRecArray.push(presetOutRec) 
    instrument1 = "999"
    instrument2 = "999"
    instrument3 = "999"
    instrument4 = "999"
    instrument5 = "999"
    instrument6 = "999"
    instrument7 = "999"
    instrument8 = "999"
    instrument9 = "999"
    instrument10 = "999"            
    presetInstrumentOutArray = []
    #logfile.puts presetOutRec
    presetInstrumentCntr += 1
end

# Write out presets to a file
filename = directoryname + "/.presets.info"
presetfile = File.new(filename,"w+")  
presetRecArray.each do |presetRec|
    presetfile.puts presetRec
end 
presetfile.close


# Write out instrument Arrays (.pisf files)

outArray = []
sampleName = ""
instrumentName = ""
lowKey = ""
highKey = ""
pisfinsert = ""
# Spin thru the instrument Array to get information about the Instrument
wavToGet = " "
instrumentArray.each do |instrumentLine|
    logfile.puts instrumentLine.to_s
    if instrumentLine.include? "InstrumentName"
        instrumentName = instrumentLine.partition("=").last
    end
    if instrumentLine.include? "Sample"    
        sampleName = instrumentLine.partition("=").last
        wavToGet = directoryname + "/" + sampleName[0..sampleName.length-2] + ".wav"
        if File.exists? wavToGet
            pisfinsert = readWav(wavToGet, 0)
        end          
    end
    if instrumentLine.include? "Z_LowKey"
        lowKey = instrumentLine.partition("=").last
    end

    overridingRootKey = 0
    if instrumentLine.include? "Z_overridingRootKey"
        overridingRootKey = instrumentLine.partition("=").last
        logfile.puts "Z_overridingRootKey: " + overridingRootKey.to_s
        logfile.puts "wavToGet: " + wavToGet.to_s
        if File.exists? wavToGet
            logfile.puts "Calling pfinsert build again"
            pisfinsert = readWav(wavToGet, overridingRootKey) # build it again to ovveride the base sample key          
        end
        # delete records already written
        lowKeyint = lowKey.to_i 
        highKeyint = highKey.to_i 
        for i in lowKeyint..highKeyint 
            outArray.pop
        end
        # Add them back with new base note
        for i in lowKeyint..highKeyint          
            logfile.puts "sampleName: " + sampleName.to_s
            #sampleBaseKey = findSampleBaseKey(sampleName, sampleArray)
            sampleBaseKey = pisfinsert.split(",")[6]
            logfile.puts "sampleBaseKey: " + sampleBaseKey.to_s
            logfile.puts "i: " + i.to_s                                                        
            noteRate = noteOffset(sampleBaseKey, i).round(5)
            logfile.puts "noteRate: " + noteRate.to_s
            outrec = instrumentName.to_s[0..instrumentName.length-2] + "," + i.to_s + "," + noteRate.to_s + "," + sampleName.to_s[0..sampleName.length-2] + "," + pisfinsert.to_s
            logfile.puts "outrec: " + outrec.to_s
            outArray.push(outrec)
            logfile.puts outrec
        end
    end
  
    if instrumentLine.include? "Z_HighKey"
        highKey = instrumentLine.partition("=").last
        #last parameter in a instrument sample  ... assumes all samples in an instrument have a highkey
        lowKeyint = lowKey.to_i 
        highKeyint = highKey.to_i 
        for i in lowKeyint..highKeyint          
            logfile.puts "sampleName: " + sampleName.to_s
            #sampleBaseKey = findSampleBaseKey(sampleName, sampleArray)
            sampleBaseKey = pisfinsert.split(",")[6]
            logfile.puts "sampleBaseKey: " + sampleBaseKey.to_s
            logfile.puts "i: " + i.to_s                                                        
            noteRate = noteOffset(sampleBaseKey, i).round(5)
            logfile.puts "noteRate: " + noteRate.to_s
            outrec = instrumentName.to_s[0..instrumentName.length-2] + "," + i.to_s + "," + noteRate.to_s + "," + sampleName.to_s[0..sampleName.length-2] + "," + pisfinsert.to_s
            logfile.puts "outrec: " + outrec.to_s
            outArray.push(outrec)
            logfile.puts outrec
        end
    end                                   
end

lastInstrument = outArray[0].split(",")[0]
singleInstrumentArray = []
i = 0
outArray.each do |outRec|
    currentInstrument = outArray[i].split(",")[0]
    if currentInstrument == lastInstrument
        singleInstrumentArray.push outRec
    else
        # set up output file
        filename = directoryname + "/" + lastInstrument + ".pisf" 
        puts filename.to_s
        outfile = File.new(filename,"w+")        

        noteNum = singleInstrumentArray[0].split(",")[1]
        singleInstrumentArrayPos = 0 
        #outrec = ""
        singleInstrumentArray.each do |instrumentRec|
            recToMatch = instrumentRec
            noteToFind = instrumentRec.split(",")[1]
            matchArrayPos = 0
            recMatch = "N" 
            singleInstrumentArray.each do |matchLine|
                if matchArrayPos > singleInstrumentArrayPos
                    noteFound = matchLine.split(",")[1]
                    if noteFound == noteToFind
                        recMatch = "Y"
                        recNumMatch = matchArrayPos
                        break
                    end
                end
                #read next record
                matchArrayPos += 1
            end
            if recMatch == "Y"
                newrec = recToMatch[0..recToMatch.length-2] + "," + matchArrayPos.to_s  # next multisample to link to
            else
                newrec = recToMatch[0..recToMatch.length-2] + ",0" # no multisample to link to
            end
            outfile.puts newrec
            singleInstrumentArrayPos += 1 
        end
        lastInstrument = currentInstrument
        outfile.close
        singleInstrumentArray = []
    end
    i += 1  
end

# Write out last instrument not processed by last instrument processing above
        
# set up output file
filename = directoryname + "/" + lastInstrument + ".pisf" 
puts filename.to_s
outfile = File.new(filename,"w+")        

noteNum = singleInstrumentArray[0].split(",")[1]
singleInstrumentArrayPos = 0 
#outrec = ""
singleInstrumentArray.each do |instrumentRec|
    recToMatch = instrumentRec
    noteToFind = instrumentRec.split(",")[1]
    matchArrayPos = 0
    recMatch = "N" 
    singleInstrumentArray.each do |matchLine|
        if matchArrayPos > singleInstrumentArrayPos
            noteFound = matchLine.split(",")[1]
            if noteFound == noteToFind
                recMatch = "Y"
                recNumMatch = matchArrayPos
                break
            end
        end
        #read next record
        matchArrayPos += 1
    end
    if recMatch == "Y"
        newrec = recToMatch[0..recToMatch.length-2] + "," + matchArrayPos.to_s  # next multisample to link to
    else
        newrec = recToMatch[0..recToMatch.length-2] + ",0" # no multisample to link to
    end
    outfile.puts newrec
    singleInstrumentArrayPos += 1 
end
outfile.close

# Build Drumkit

presetRecArray.each do |presetRec|
    presetInstrumentRec = ""
    presetRecName = presetRec.split(",")[2]
    presetBank = presetRec.split(",")[0]
    #logfile.puts "presetBank: " + presetBank.to_s
    presetProgram = presetRec.split(",")[1]
    #logfile.puts "presetProgram: " + presetProgram.to_s
    #logfile.puts "presetRec: " + presetRec.to_s
    #puts "presetInstrumentArray length: " + presetInstrumentArray.length.to_s
    presetInstrumentCntr = 0
    lowKeyCntr = 0
    highKeyCntr = 0
    lowVelocityCntr = 0
    highVelocityCntr = 0
    initialFilterFcCntr = 0
    panCntr = 0
    fineTuneCntr = 0
    i = 1
    drumInstrumentsForPreset = []
    if presetBank.to_s == "128"
        logfile.puts "Processing Drumkit: " + presetRec.to_s
        #determine how many instruments in drum preset
        10.times do
            presetDrumInstrumentTest = presetRec.split(",")[i*8+3].to_s
            logfile.puts "presetDrumInstrumentTest: " + presetDrumInstrumentTest.to_s
            if presetDrumInstrumentTest.to_s == "999"
                presetInstrumentName = presetRec.split(",")[i*8+2]
                drumInstrumentsForPreset.push(presetInstrumentName)
                logfile.puts "presetInstrumentName: " + presetInstrumentName.to_s
                break    
            else    
                presetInstrumentName = presetRec.split(",")[i*8+2]
                drumInstrumentsForPreset.push(presetInstrumentName)
                logfile.puts "presetInstrumentName: " + presetInstrumentName.to_s
                i += 1
            end
        end
        logfile.puts "i: " + i.to_s    
        logfile.puts "drumInstrumentsForPreset length: " + drumInstrumentsForPreset.length.to_s
        logfile.puts "drumInstrumentsForPreset: " + drumInstrumentsForPreset.to_s
        #presetName = presetRec.split(",")[0]
        #instrumentName = presetRec.split(",")[1].chop
        # process drum instruments
        drumArrayOut = []

        #populate default values in drumArrayOut
        drumCntr = 0
        128.times do
            drumRecOut = "NoDrumInstrument" + "," + drumCntr.to_s + ",1.0,NoDrumSample,0"
            drumArrayOut[drumCntr] = drumRecOut
            drumCntr += 1
        end
        
        drumInstrumentsForPreset.each do |drumInstrument|

            drumFileName = directoryname + "/" + drumInstrument + ".pisf"
            logfile.puts "drumFile: " + drumFileName.to_s  
            drumFile = File.open(drumFileName, 'r') 
            drumInArray = drumFile.readlines
            drumFile.close
            logfile.puts "drumInArray length: " + drumInArray.length.to_s
            # open the array
            drumInArray.each do |drumRecIn|
                drumInstrument = drumRecIn.split(",")[0]
                midiNote = drumRecIn.split(",")[1]
                drumSample = drumRecIn.split(",")[3]
                drumRecOut = drumInstrument.to_s + "," + midiNote.to_s + "," + "1.0" + "," + drumSample.to_s + "," + "0"
                #check to see if sample file exists
                logfile.puts "drumSample: " + drumSample.to_s
                testFileName = directoryname + "/" + drumSample + ".wav"
                logfile.puts "testFileName: " + testFileName.to_s
                fileTest = File.file?(testFileName)
                logfile.puts "fileTest: " + fileTest.to_s
                if fileTest == true
                    drumArrayOut[midiNote.to_i] = drumRecOut.to_s # he who writes last wins if 2 drum instruments are for the same midi note   
                end
            end
        end

        #output DrumKit File as a .pisf
        filename = directoryname + "/" + presetRecName + ".pisf" 
        puts filename.to_s
        outfile = File.new(filename,"w+")

        logfile.puts "drumKit Array"
        logfile.puts "drumKitName: " + presetRecName.to_s
        drumArrayOut.each do |zdrumRecOut|
            logfile.puts zdrumRecOut.to_s
            outfile.puts zdrumRecOut.to_s
        end
        outfile.close
    end
end

# Fix up Preset Array for drumkits to work in Sonic Pi
presetFileName = directoryname + "/.presets.info"
presetFile = File.open(presetFileName, 'r') 
presetInArray = presetFile.readlines
presetFile.close

presetOutArray = []
presetCntr = 0
presetInArray.each do |presetLineIn|
    presetRecName = presetLineIn.split(",")[2]
    presetBank = presetLineIn.split(",")[0]
    presetProgram = presetLineIn.split(",")[1]
    #logfile.puts "presetBank: " + presetBan 
    if presetBank.to_s == "128" # fix up record
        presetOutRec = presetBank + "," + presetProgram + "," + presetRecName + ",0,127,0,127,0,0,0," + presetRecName + ",999,999,999,999,999,999,999,999,999" 
        presetOutArray[presetCntr] = presetOutRec
    else
        presetOutArray[presetCntr] = presetLineIn
    end
    presetCntr += 1
end

# overlay preset.info file with fixed up version 
filename = directoryname + "/.presets.info" 
puts filename.to_s
outfile = File.new(filename,"w+")
presetOutArray.each do |presetLine|
    outfile.puts presetLine.to_s
end
outfile.close

logfile.close
