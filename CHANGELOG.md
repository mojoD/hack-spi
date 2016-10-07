# History 

## Version 2.0 - 'Basically Better'
+ Sunday 16th, October, 2016 

**"A True Working Solution"**

The major components of Release 2 include:
+ sf2spi.rb - converts soundfont files to .pisf files that allow you to play soundfont instruments in Sonic Pi
+ midi2spi.rb - converts midi files to midiloop (.mloop) files & generate Ruby code to play them in Sonic Pi 
+ MidiotBaseProgram.rb - Sonic Pi plugin that plays the mloop files and soundfont instruments
+ midithruServer.rb - connects midi controller devices to Sonic Pi
+ midithruClient.rb - Sonic Pi plugin that consumes the incoming midi from the midi controller and plays synths and samples   
+ SpiVizServer.rb - Sonic Pi plugin that sends graphics language (gl) commands to the new Sonic Pi Visualizer
+ SpiViz.rb - opengl based music visualizer that is controlled from Sonic Pi
+ init.rb - installs "plugins" for Sonic Pi
+ getclips.rb - helper code that allows you to paste code snippets into Sonic Pi via a standard file dialog




## Version 1.0 - 'Arduous Amore'
+ Sunday 12th, August, 2016
 
**"A Labor of Love"**

This is the first public release of the software.  As such, it is in what I would consider an *Alpha Release*.  It doesn't have any error checking to speak of.  The documentation is in the attached Wiki and it is not linked within the Sonic Pi documentation system.

The major components of Release 1 are:
+ sf2sonicpi0.rb - program to convert soundfont files to .pisf files that work in Sonic Pi
+ midi2sonicpi0.rb - program to convert midi files to midiloop (.mloop) files & generate Ruby code to play them in Sonic Pi
+ MidiotBaseProgram0.rb - ruby code that runs in Sonic Pi to implement the Midiot.

MidiotBaseProgram Functionality:
+ Play soundfont sample based instruments that can play any note for any duration for up to 127 different instruments within Live-loops
+ Play midiloops using the new soundfont sample based instruments 
+ Play midiloops using the Sonic Pi synths 
+ Play portions of midiloops by slicing the input and looping the sliced result
+ Transpose the midiloop 

