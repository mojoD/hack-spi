# Hack-SPi Project
This Hack-SPi Github Project is where I have decided to store all my extensions and plugins that I have created for Sonic Pi.  It is called Hack-SPi because I primarily developed this for my use and I am not making changes directly to the Sonic Pi Code Base.  I don't expect that much of it will show up in the actual Sonic Pi distribution as it is not done by the Core Development Team.  These are all considered prototypes, although they are very fully developed in terms of functionality, they lack robust error handling, installers, integrated help system, etc.  

If the core developers have interest in this code they are invited to pull down the code and treat it as prototype code that they can further enhance.  If you are a Sonic Pi User or Hacker like me, you are also encouraged to download it and give it a whirl.  The main project is made up of a number of smaller sub-projects that I have worked.  All the code is contained in this master branch.  The sub-projects include:
+ Soundfont: adds soundfont instruments in Sonic Pi in addition to samples and synths.
+ Midiot: plays complete midi songs, tracks or slices of tracks in Sonic Pi using soundfont instruments, samples or synths. 
+ Midithru: hook up midiIn controllers to Sonic Pi to play synths, samples and soundfont instruments.
+ SpiViz: a Ruby based openGL language for Sonic Pi to have graphics controlled in liveloops to do music visualization.
+ GetClips: inserts instruments, samples, synths, patterns, midiloops, etc code snippets easily into Sonic Pi vis file dialog.

# Soundfont Instruments
## Sub-Project Goal
+ Create conversion program to read a soundfont file and for each instrument in it create a file that is used by Sonic Pi.
+ Create command in Sonic Pi that allows you to play a note using these Soundfont Instruments.
+ Soundfont Instruments should be able to hold a note for any duration unlike regular Samples.
+ Soundfont Instruments should have the basic sample options available.
+ Soundfont Instruments can be played much like using play for synths.
+ Soundfont Instruments can be played by midithru controllers.

## Soundfont Instruments Documentation

There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation. Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your "Live Coding" performances.

Go to the Wiki: https://github.com/mojoD/hack-spi/wiki/2)-Soundfonts-and-sf2sonicpi

Link to Introduction Youtube Video Playlist: https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ

# The Midiot and midiloops Sub-project
## Sub-Project Goal  
+ Be able to seamlessly translate Midi files for use in Sonic Pi.  
+ Create Sonic Pi functionality that will allow the ability to play midi using Soundfont instruments, samples & synths.  
+ Be able to pull in midi files, midi tracks or portions/slices of midi tracks that can be used in Sonic Pi live-loops to add another option to complement the sending of individual notes, arrays of notes as currently done in Sonic Pi.  
+ Allows you to pull in these midi "licks" with fragments of melodies much easier than manually entering them in Sonic Pi. 
+ Create a library of Midisongs and midiloops that can be downloaded for use in live coding.

## Midiot Documentation
There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation.  Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your **"Live Coding"** performances.

**Go to the Wiki:**  
+ https://github.com/mojoD/hack-spi/wiki/3)-Midi-and-midi2sonicpi
+ https://github.com/mojoD/hack-spi/wiki/4)-Using-Midiot-in-Sonic-Pi

**Link to Introduction Youtube Video Playlist:**   https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ

# Midithru - use midi controllers to play along with Sonic Pi
## Sub-Project Goal
+ Hook up 1 or more midi controllers with low latency.
+ Map midi controllers to Soundfont Instrument, sample or synth.
+ Sonic Pi plays mapped instrument based on the key pressed.
+ Midi Controller commands include keys, buttons & knobs.
+ Midi Controller can control more than note played (i.e. cutoff parameters, slide values, etc).

## Midithru Documentation

There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation. Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your "Live Coding" performances.

Go to the Wiki: https://github.com/mojoD/hack-spi/wiki/5)-Using-Midithru-in-Sonic-Pi

Link to Introduction Youtube Video Playlist: https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ

# SpiViz - Music Visuzlizer
## Sub-Project Goal 
+ Create a Ruby based language with openGL bindings.
+ Create a Ruby Server with Graphics Language (gl) commands that can be called from Sonic Pi.
+ Create a Ruby Client that runs in Sonic Pi to send commands to Ruby openGL Server via UDP.
+ Create a library of Graphic Primitive Shapes whose appearance can be controlled from Sonic Pi.
+ Create ability to move, rotate and scale shapes dynamically from Sonic Pi.
+ Create GLSL Shader bindings for advanced music visualizations.

## SpiViz Documentation

There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation. Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your "Live Coding" performances.

Go to the Wiki: 
+ https://github.com/mojoD/hack-spi/wiki/7)-SpiViz-Music-Visualization
+ https://github.com/mojoD/hack-spi/wiki/8-)-SpiViz-Command-Reference

Link to Introduction Youtube Video Playlist: https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ


# GetClips - select from code snippet library 
## Sub-Project Goal 
+ Build library of code snippets for Synths, Samples, Soundfont Instruments, OpenGL commands, Sonic Pi language elements, etc.
+ Create standard file dialog to select snippets from library and copy to clipboard.
+ Paste into Sonic Pi using existing clipboard paste functionality.
+ Map calling of this GetClips file dialog to function key (F2 in Windows).

## GetClips Documentation

There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation. Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your "Live Coding" performances.

Go to the Wiki: https://github.com/mojoD/hack-spi/wiki/6)-Using-GetClips

Link to Introduction Youtube Video Playlist: https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ

