# History 

**V1.0 - 'Arduous Amore'**, 12 August, 2016

## Version 1.0 - 'Arduous Amore'
+ Sunday 12th, August, 2016
 
_ "A Labor of Love"

This is the first public release of the software.  As such, it is in what I would consider a Alpha Release.  It doesn't have any error checking to speak of.  The documentation is in the attached Wiki and it is not linked within the Sonic Pi documentation system.

The major components of Release 1 are:
+ sf2sonicpi0.rb - program to convert soundfont files to .pisf files that work in Sonic Pi
+ midi2sonicpi0.rb - program to convert midi files to midiloop (.mloop) files and generate Ruby code to play them in Sonic Pi
+ MidiotBaseProgram0.rb - ruby code that runs in Sonic Pi to implement the Midiot.

MidiotBaseProgram Functionality:
+ Play soundfont sample based instruments that can play any note for any duration for up to 127 different instruments within Live-loops
+ Play midiloops using the new soundfont sample based instruments 
+ Play midiloops using the Sonic Pi synths 
+ Play portions of midiloops by slicing the input and looping the sliced result
+ Transpose the midiloop 


