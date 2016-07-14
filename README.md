# midiloops
Goal:  Be able to seamlessly translate Midi files for use in Sonic Pi that will utilize samples derived from a Soundfont file. 

The concept behind midiloops is to first take a Soundfont file and run a program (sf2Sonicpi0.rb) to extract it so that it can be consumed by the sample command in Sonic Pi that uses the SuperCollider soft synth.  With the soundfont samples available to Sonic Pi then you take midifiles and run them through a program (midi2SonicPi0.rb) that creates a set of files that are called midiloops that are played in Sonic Pi and also generates ruby code for Sonic Pi that act as a Sequencer (sequencer.rb) or Loop Player (looper.rb).  These ruby files are then loaded into Sonic Pi to play the midisong that was converted to the .mloop extension files.  

The usage for the sf2SonicPi0.rb program is sf2SonicPi0.rb [input SoundfontFile] [output directory].
The usage for the midi2SonicPi0.rb program is midi2SonicPi0.rb [input midifile] [output directory].

sf2SonicPi Documentation:

Soundfonts were originally introduced by Creative Software for an easy way to store the samples and sound shaping for the 128 midi instruments and drum kit samples for each drum.  It was originally for use with Creative Soundblaster sound cards.  There are a lot of publically available soundfont files that can have been created for free and purchase that contain sample sets for use in software synthesizers.  The sf2SonicPi0 program translates these soundfont file into a set of intermediate files that are used by Sonic Pi to assign the samples to the midifile to be played.  

The sf2SonicP0 program:
  - reads in the soundfont file using a helper program (sf2comp.exe) to decompile the binary soundfont file to be used in the program
  - creates a .preset.info file that contains the settings for each of the 128 midi instruments, as well as, all the drum kits
  - extracts all the Wav files with samples contained in the soundfont binary file
  - creates a file for each midi instrument and drumkit that contains the midi note, rate offset and sample wav file used by Sonic Pi

midi2SonicPi Documentation:

A little background about the approach to midi before discussing the midi2SonicPi0.rb program.  There are up to 16 tracks in a Midifile. By convention Track 10 is the drums.  The instruments are in Tracks 1-9 and 11-16.  In the normal instrument Midi tracks the midinote represents the note on the scale to play (i.e. 60 is middle C).  In the Drum Track 10, the midi notes represent the drum to play.  This means they are handled a little bit differently when creating the midiloop files.     

The midi2SonicPi0 program:
  - reads in the midifile which is binary and extracts it to be used in the program
  - creates 1 midiloop file for each instrument track (non Track 10).  
  - creates a Mixer/Sequencer in ruby.
  - generates ruby code for a Sequencer that plays the midi file in Sonic Pi.
  - generates ruby code for a Loop Player that plays the midifiles in individual live loops to be used in Live Coding Performances.

For example, using a midifile for the Fleetwood Mac song Dreams it creates the following midiloops.
 Instruments: 
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_01 - DREAMS              - Bright Acoustic Piano.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_02 - DREAMS            2 - Electric Bass (finger).mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_03 - DREAMS            3 - Acoustic Guitar (steel).mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_04 - DREAMS            4 - Flute.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_05 - DREAMS            5 - Synth Voice.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_06 - DREAMS            6 - Synth Voice.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_07 - DREAMS            7 - Electric Guitar (jazz).mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_08 - DREAMS            8 - String Ensemble 1.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_09 - DREAMS            9 - String Ensemble 2.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_09 - DREAMS           10 - PopDrums.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_11 - DREAMS           11 - Vibraphone.mloop
 
The midiloop Files have the following information in them.
- Midi Patch/Program that was in the Midifile for the Instrument Tracks
- MidiNote played
- Velocity for the Note
- Start Time of the Note
- Duration of the Note

The next part of the midiloops approach is a to play these midiloops with Sonic Pi.  This is done using the two ruby programs (sequencer.rb & looper.rb) that were generated when running midi2SonicPi0.rb.  The basic approach is to read the midiloop into an array/list in Sonic Pi and then use live loops to play the note, apply note velocity as attack, use start time to find the first sleep value, and use note duration in calculating release time and sleep values.  The appropriate midi instrument to use for each midi loop is controlled by the midi mixer that is generated for both sequence.rb and looper.rb.

sequencer.rb was designed to be used as a simple midi player where the musician could control what is played by changing settings in the mixer portion of the code which looks like: 

mMixer = [\

1,"sample",0,1,"Bright Acoustic Piano",1.4,"play","mono","novelocity","NoEffects",\ 

2,"sample",0,33,"Electric Bass (finger)",1.6,"play","mono","novelocity","NoEffects",\ 

3,"sample",0,25,"Acoustic Guitar (steel)",1.2,"play","mono","novelocity","NoEffects",\

4,"sample",0,73,"Flute",1.8,"play","mono","novelocity","NoEffects",\

5,"sample",0,54,"Synth Voice",1.6,"play","mono","novelocity","NoEffects",\

6,"sample",0,54,"Synth Voice",1.6,"play","mono","novelocity","NoEffects",\

7,"sample",0,26,"Electric Guitar (jazz)",1.8,"play","mono","novelocity","NoEffects",\

8,"sample",0,48,"String Ensemble 1",1.3,"play","mono","novelocity","NoEffects",\

9,"sample",0,49,"String Ensemble 2",1.0,"play","mono","novelocity","NoEffects",\

10,"sample",128,0,"Drum Kit",1.4,"play","mono","novelocity","NoEffects",\

11,"sample",0,11,"Vibraphone",1.0,"play","mono","novelocity","NoEffects",\

12,"sample",0,31,"Guitar harmonics",1.1,"play","mono","novelocity","NoEffects"\

]


The format of the mixer line is:  track #, sample or synth to play, bank, program, track name, amp, play/mute, mono/stereo, velocity aware, effects


