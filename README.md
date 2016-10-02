# Hack-SPi Project
The Hack-SPi Project is where I have decided to store all my extensions and plugins that I have created for Sonic Pi.  It is called Hack-SPi because I primarily developed this for my use.  I don't expect that much of it will show up in the actual Sonic Pi distribution.  I encourage developers to pull down the code and integrate it into Sonic Pi if it is of interest to them.  The main project is made up of a number of smaller sub-projects that I have worked.  All the code is contained in this master branch.  The sub-projects include:
+ Soundfont: adds soundfont instruments in Sonic Pi in addition to samples and synths.
+ Midiot: plays complete midi songs, tracks or slices of tracks in Sonic Pi using soundfont instruments, samples or synths. 
+ Midithru: hook up midiIn controllers to Sonic Pi to play synths, samples and soundfont instruments.
+ SpiViz: a Ruby based openGL language for Sonic Pi to have graphics controlled in liveloops to do music visualization.
+ Insert: inserts instruments, samples, synths, patterns, midiloops, etc code snippets easily into Sonic Pi vis file dialog.

# Soundfont Instruments
## Sub-Project Goal​

# The Midiot and midiloops Sub-project
## Sub-Project Goal  
+ Be able to seamlessly translate Midi files for use in Sonic Pi that will utilize samples derived from a Soundfont file.  
+ Create Sonic Pi functionality that will allow the ability to utilize Soundfont instruments, samples and synths.  
+ Be able to pull in midi files, midi tracks or portions/slices of midi tracks that will can be used in Sonic Pi live-loops to add another option to complement the sending individual notes, arrays of notes as currently done in Sonic Pi.  
+ Allow you pull in these midi "licks" with fragments of melodies much easier than manually entering them in Sonic Pi as you do today as notes to play and sleep commands. 
+ Create a library of Midisongs and midiloops that can be downloaded to be used in live coding.

## Midiot Documentation
There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation.  Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your **"Live Coding"** performances.

**Go to the Wiki:**  https://github.com/mojoD/hack-spi/wiki

**Link to Introduction Youtube Video Playlist:**   https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ

# Midithru - use midi controllers to play along with Sonic Pi
## Sub-Project Goal
+ Hook up 1 or more midi controllers with low latency.
+ Map midi controllers to Soundfont Instrument, sample or synth.
+ Sonic Pi plays mapped instrument based on the key pressed.
+ Midi Controller commands include keys, buttons & knobs.
+ Midi Controller can control more than note played (i.e. cutoff parameters, slide values, etc).

## Midithru Documentation


# SpiViz - Music Visuzlizer
## Sub-Project Goal 
+ Create a Ruby based language with openGL bindings.
+ Create a Ruby Server with GL commands that can be called from Sonic Pi.
+ Create a Ruby Client that runs in Sonic Pi to send commands to GL Server via UDP.
+ Create a library of GL Primitive Shapes whose appearance can be controlled from Sonic Pi.
+ Create ability to move, rotate and scale shapes dynamically from Sonic Pi.
+ Create GLSL Shader bindings for advanced music visualizations.

## SpiViz Documentation


# Inserter - select from code snippet library 
## Sub-Project Goal 
+ Build library of code snippets for Synths, Samples, Soundfont Instruments, OpenGL commands, Sonic Pi language elements
+ Create stand file dialog to select snippets from library and copy to clipboard
+ Paste into Sonic Pi using existing clipboard paste functionality
+ Map calling of this Inserter file dialog to function key (F2 in Windows)

## SpiViz Documentation
