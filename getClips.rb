#!/usr/bin/env ruby -rubygems

require 'tk'
require 'clipboard'

root = TkRoot.new { title "Pick File" }
TkLabel.new(root) do
   pack { padx 15 ; pady 15; side 'left' }
   filename = Tk::getOpenFile
   copytext = ""
   open(filename).each_line do |line| #unless filename.empty?
 	    copytext = copytext + line.to_s + "\r\n"
   end
   Clipboard.copy(copytext)	
   root.destroy()
end
Tk.mainloop