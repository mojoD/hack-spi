# Hack-SPi Project
The Hack-SPi Project is where I have decided to store all my extensions and plugins that have created for Sonic Pi.  It is made up of a number of smaller sub-projects.  All the code is contained in this master branch.  The sub-projects include:
+ Midiot: playing of midi tracks or portions of tracks in Sonic Pi. 
+ Soundfont: add soundfont instruments in Sonic Pi in addition to samples and synths.
+ Midithru: hook up midiIn controllers to Sonic Pi to play synths, samples and SF instruments.
+ Visualizer: create Ruby based openGL language for Sonic Pi to have graphics controlled in liveloops.
+ Insert: Insert instruments, samples, synths, patterns, midiloops, etc easily into Sonic Pi.

# The Midiot and midiloops Sub-project
## Project Goal  
+ Be able to seamlessly translate Midi files for use in Sonic Pi that will utilize samples derived from a Soundfont file.  
+ Create Sonic Pi functionality that will allow the ability to utilize Soundfont instruments in addition to the current sample and synth instruments.  
+ Be able to pull in midi files, midi tracks or portions/slices of midi tracks that will can be used in Sonic Pi live-loops to add another option to complement the sending individual notes, arrays of notes as currently done in Sonic Pi.  
+ Allow you pull in these midi "licks" with fragments of melodies much easier than manually entering them in Sonic Pi as you do today as notes to play and sleep commands.   

## Documentation
There is a Wiki that is attached to this project in GitHub that contains user manuals and technical documentation.  Also, a youtube playlist is available with tutorials showing how to use Midiot as a Midi Song Player or integrate it into your **"Live Coding"** performances.

**Go to the Wiki:**  https://github.com/mojoD/hack-spi/wiki

**Link to Introduction Youtube Video Playlist:**   https://www.youtube.com/playlist?list=PLYuaqec79vK7t49cBIiNMy7XIjdaytAnZ
