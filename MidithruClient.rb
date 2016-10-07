#!/usr/bin/env ruby -rubygems
# Sonic Pi Midiot Base Program V0

require "FileUtils"
require 'socket'
require_relative 'MidiotBaseProgram'

def midithru(midiInstrument)

  synthType = midiInstrument.to_s.split(" ")[0]
  synthToUse = midiInstrument.to_s.split(" ")[1]
  parmArray = []
  parmArray = midiInstrument.to_s.split(",")
  i = 0
  parms = ""
  #default values for soundfont instruments
  amp = 1.0
  instAmp = 1.0
  instPan = 0.0
  instRelease = 1.0
  instbpm = 60
  instgmBank = "000"
  instgmPatch = "000"
  instgmPathDir = "C:/Users/Michael Sutton/Midiloop/default/"
  instAttack = 0.01
  instDecay = 0.3
  instSustain = 0.5
  instlpf = 128
  insthpf = 1
  transpose = 0

  parmArray.length.to_i.times do
    puts "i: " + i.to_s
    if i.to_i != 0
      if i.to_i == parmArray.length.to_i - 1 
        parms = parms + parmArray[i].to_s
        puts "parm1: " + parmArray[i].to_s
      else
        if i.to_i == 1
          parms = parmArray[i].to_s + ","
        else
          parms = parms + parmArray[i].to_s + ","
        end      
      end
    end
    i += 1
  end
  
  puts "synthType: " + synthType.to_s
  case synthType.to_s
  when "use_synth"
    synthToUse[0] = ""
    if synthToUse.include? ","
      synthToUse = synthToUse.chop
    end
    puts "synthToUse: " + synthToUse.to_s
    use_synth synthToUse.to_sym
    parmArray.each do |cmdLine|
      cmdTest = cmdLine.split(':')
      cmd = cmdTest[0].strip
      cmdVal = cmdTest.last.strip
      case cmd.to_s
      when "amp"
        puts "amp: " + cmdVal.to_s
        use_synth_defaults amp: cmdVal.to_f
        amp = cmdVal.to_f
      when "amp_slide"
        use_synth_defaults amp_slide: cmdVal.to_f
      when "attack"
        use_synth_defaults attack: cmdVal.to_f        
      when "attack_level"
        use_synth_defaults attack_level: cmdVal.to_f
      when "coef"
        use_synth_defaults coef: cmdVal.to_f               
      when "cutoff"
        use_synth_defaults cutoff: cmdVal.to_i
      when "cutoff_min"
        use_synth_defaults cutoff_min: cmdVal.to_f
      when "cutoff_attack"
        use_synth_defaults cutoff_attack: cmdVal.to_f
      when "cutoff_decay"
        use_synth_defaults cutoff_decay: cmdVal.to_f
      when "cutoff_sustain"
        use_synth_defaults cutoff_sustain: cmdVal.to_f
      when "cutoff_release"
        use_synth_defaults cutoff_release: cmdVal.to_f
      when "cutoff_attack_level"
        use_synth_defaults cutoff_attack_level: cmdVal.to_f
      when "cutoff_decay_level"
        use_synth_defaults cutoff_decay_level: cmdVal.to_f
      when "cutoff_sustain_level"
        use_synth_defaults cutoff_sustain_level: cmdVal.to_f
      when "decay"
        use_synth_defaults decay: cmdVal.to_f
      when "decay_level"
        use_synth_defaults decay_level: cmdVal.to_f
      when "depth"
        use_synth_defaults depth: cmdVal.to_f
      when "detune"
        use_synth_defaults detune: cmdVal.to_f
      when "detune1"
        use_synth_defaults detune1: cmdVal.to_f
      when "detune2"
        use_synth_defaults detune2: cmdVal.to_f
      when "disable_wave"
        use_synth_defaults disable_wave: cmdVal.to_i
      when "divisor"
        use_synth_defaults divisor: cmdVal.to_f     
      when "dpulse_width"
        use_synth_defaults dpulse_width: cmdVal.to_f        
      when "env_curve"
        use_synth_defaults env_curve: cmdVal.to_i
      when "freq_band"
        use_synth_defaults freq_band: cmdVal.to_i
      when "hard"
        use_synth_defaults hard: cmdVal.to_f
      when "invert_wave"
        use_synth_defaults invert_wave: cmdVal.to_i
      when "max_delay_time"
        use_synth_defaults max_delay_time: cmdVal.to_f
      when "mod_phase"
        use_synth_defaults mod_phase: cmdVal.to_f
      when "mod_range"
        use_synth_defaults mod_range: cmdVal.to_f
      when "mod_pulse_width"
        use_synth_defaults mod_pulse_width: cmdVal.to_f
      when "mod_phase_offest"
        use_synth_defaults mod_phase_offest: cmdVal.to_f
      when "mod_invert_wave"
        use_synth_defaults mod_invert_wave: cmdVal.to_i
      when "mod_wave"
        use_synth_defaults mod_wave: cmdVal.to_i 
      when "noise"
        use_synth_defaults noise: cmdVal.to_i
      when "noise_amp"
        use_synth_defaults noise_amp: cmdVal.to_f
      when "norm"
        use_synth_defaults norm: cmdVal.to_i
      when "note"
        use_synth_defaults note: cmdVal.to_i
      when "note_resolution"
        use_synth_defaults note_resolution: cmdVal.to_f      
      when "on"
        use_synth_defaults on: cmdVal.to_i
      when "pan"
        use_synth_defaults pan: cmdVal.to_f
      when "pan_slide"
        use_synth_defaults pan_slide: cmdVal.to_f
      when "phase"
        use_synth_defaults phase: cmdVal.to_f
      when "phase_offset"
        use_synth_defaults phase_offset: cmdVal.to_f
      when "pitch"
        use_synth_defaults pitch: cmdVal.to_f
      when "pluck_decay"
        use_synth_defaults pluck_decay: cmdVal.to_f
      when "pulse_width"
        use_synth_defaults pulse_width: cmdVal.to_f
      when "range"
        use_synth_defaults range: cmdVal.to_f
      when "release"
        use_synth_defaults release: cmdVal.to_f
      when "res"
        use_synth_defaults res: cmdVal.to_f        
      when "reverb_time"
        use_synth_defaults reverb_time: cmdVal.to_f
      when "ring"
        use_synth_defaults ring: cmdVal.to_f
      when "room"
        use_synth_defaults room: cmdVal.to_f
      when "slide"
        use_synth_defaults slide: cmdVal.to_f        
      when "stereo_width"
        use_synth_defaults stereo_width: cmdVal.to_f
      when "sub_amp"
        use_synth_defaults sub_amp: cmdVal.to_f
      when "sub_detune"
        use_synth_defaults sub_detune: cmdVal.to_f
      when "sustain"
        use_synth_defaults sustain: cmdVal.to_f
      when "sustain_level"
        use_synth_defaults sustain_level: cmdVal.to_f
      when "vibrato_rate"
        use_synth_defaults vibrato_rate: cmdVal.to_f
      when "vibrato_depth"
        use_synth_defaults vibrato_depth: cmdVal.to_f
      when "vibrato_delay"
        use_synth_defaults vibrato_delay: cmdVal.to_f
      when "vibrato_onset"
        use_synth_defaults vibrato_onset: cmdVal.to_f
      when "vel"
        use_synth_defaults vel: cmdVal.to_f
      when "wave"
        use_synth_defaults wave: cmdVal.to_i
      when "width"
        use_synth_defaults width: cmdVal.to_i
      when "transpose" 
        transpose = cmdVal.to_i
      end       
    end
  when "instrument"
    parmArray.each do |cmdLine|
      if cmdLine.to_s.include? "instrument"
        testLine = cmdLine[11...cmdLine.length.to_i]
        cmdLine = testLine
      end
      cmdTest = cmdLine.split(':')
      cmd = cmdTest[0].strip
      cmdVal = cmdTest.last.strip
      case cmd.to_s
      when "amp"
        instAmp = cmdVal.to_f
      when "pan"
        instPan = cmdVal.to_f
      when "attack"
        instAttack = cmdVal.to_f
      when "decay"
        instDecay = cmdVal.to_f
      when "release"
        instRelease = cmdVal.to_f
      when "sustain"
        instSustain = cmdVal.to_f
      when "lpfFreqCutoff"
        instlpf = cmdVal.to_f
      when "hpfFreqCutoff"
        insthpf = cmdVal.to_f  
      when "gmBank"
        instgmBank = cmdVal.to_s
      when "bpm"
        instbpm = cmdVal.to_f
      when "gmPatch"
        instgmPatch = cmdVal.to_s
      when "gmPathDir"
        instgmPathDir = "'C:" + cmdVal[1...-1].to_s + "'"
      when "transpose"
        transpose = cmdVal.to_i
      end       
    end
  end
  
  in_thread do
    require 'socket'
    BasicSocket.do_not_reverse_lookup = true
    client = UDPSocket.new
    client.bind(nil, 33555)
    udpActive = true
    oldtimestamp = 0
    puts "udpActive: " + udpActive.to_s
    midinote = 0
    durationInSecs = 0
    cntr = 0

    while udpActive do

      data, addr = client.recvfrom(1024) # if this number is too low it will drop the larger packets and never give them to you
      midiEventArray = data.split(',')
      midinote = midiEventArray[0][1...midiEventArray[0].length]
      midivelocity = midiEventArray[1]
      timestamp = midiEventArray[2][0...-1]
      if midinote.to_s == "36"
        udpActive = false
      end
      
      puts "instAmp: " + instAmp.to_s

      if timestamp.to_i > oldtimestamp.to_i
        use_timing_warnings false
        if synthType.to_s == "use_synth"
          if transpose == 0            
              play midinote.to_i, amp: amp.to_f
          else
              play midinote.to_i + transpose.to_i
          end
        end
        
        if synthType.to_s == "instrument"
          if cntr == 0 # arbitrary first note length because it is unknown
            durationInSecs = 0.5
          end 
          cntr += 1  
          instrument midinote.to_i+transpose.to_i, gmBank: instgmBank.to_s, gmPatch: instgmPatch.to_s, gmPathDir: instgmPathDir.to_s, amp: instAmp.to_f, attack: instAttack.to_f, decay: instDecay.to_f, release: instRelease.to_f, sustain: instSustain.to_f, lpf: instlpf.to_f, hpf: insthpf.to_f, pan: instPan.to_f, duration: 999.0
        end
        oldtimestamp = timestamp
        use_timing_warnings true
      end
    end
    client.close   
  end
end
