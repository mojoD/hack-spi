# midiloops
Be able to translate Midi files for use in Sonic Pi.

The concept behind midiloops is to take a midifile and run it through a program that creates a set of files that are called midiloops.  These files end with an .mloop extension.  The program that does this midi2SonicPi#.rb (where # is the latest Version).  

The usage for the midi2SonicPi#.rb program is midi2SonicPi#.rb [input midifile] [output directory]
A little background about the approach to midi before discussing the midi2SonicPi#.rb program.  There are up to 16 tracks in a Midifile. By convention Track 10 is the drums.  The instruments are in Tracks 1-9 and 11-16.  In the normal instrument Midi tracks the midinote represents the note on the scale to play (i.e. 60 is middle C).  In the Drum Track 10, the midi notes represent the drum to play.  This means they are handled a little bit differently when creating the midiloop files.     

The midi2SonicPi# program:
  - reads in the midifile
  - Creates 1 midiloop file for each instrument track (non Track 10).  
  - Creates a midiloop file for each drum in the drum kit being played in Track 10 and puts them in a separate drums directory

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
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_11 - DREAMS           11 - Vibraphone.mloop
 Drums: 
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/Track_12 - DREAMS           12 - Guitar harmonics.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_35  DrumKit - AcousticBassDrumArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_39  DrumKit - HandClapArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_40  DrumKit - ElectricSnareArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_42  DrumKit - ClosedHiHatArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_43  DrumKit - HighFloorTomArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_44  DrumKit - PedalHiHatArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_45  DrumKit - LowTomArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_46  DrumKit - OpenHiHatArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_47  DrumKit - LowMidTomArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_48  DrumKit - HiMidTomArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_49  DrumKit - CrashCymbal1Array.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_50  DrumKit - HighTomArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_57  DrumKit - CrashCymbal2Array.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_69  DrumKit - CabasaArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_70  DrumKit - MaracasArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_80  DrumKit - MuteTriangleArray.mloop
 mLoopFile: C:/Users/Michael Sutton/Documents/Midiloops/dreams/drums/Track_81  DrumKit - OpenTriangleArray.mloop

The midiloop Files have the following information in them.
- Midi Patch/Program that was in the Midifile for the Instrument Tracks
- MidiNote played
- Velocity for the Note
- Start Time of the Note
- Duration of the Note

The second part of the midiloops approach is a to play these midiloops with Sonic Pi.  The basic approach is to read the midiloop into an array/list in Sonic Pi and then use a live loop to play the note, apply note velocity as attack, use start time to find the first sleep value, and use note duration in calculating release time and sleep values.

The MidiPlayers ruby code (MidiLoopV#.rb) are cut and pasted into Sonic Pi Buffers to play in Sonic Pi.
- MidiLoopV0.rb - is a manual use of midiloops.
- MidiLoopV1.rb - is more automated and basically the user identfies the directory where the midiloops are and then can change what synths and samples to map to what midiloop and also set there volume. 
