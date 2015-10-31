require 'net/ssh'
require 'resolv'

module Quickmox

  # This class represents a SSH server host. It may or may not be
  # connected to a Proxmox server. If it's not, proxmox specific
  # methods like guests(), guest_params() etc. will return empty
  # data structures.
  class Host

    class HostError < StandardError
    end

    attr_accessor :hostname,
                  :username,
                  :password,
                  :ip,
                  :session,
                  :guests

    def initialize(transport)
      @session = transport
      @guests = Guestlist.new

      begin
        @ip = Resolv.getaddress(@session.host)
      rescue => e
        @ip = String.new
      end
    end

    def connect
      @session.connect
      self
    end

    def rescan
      scan
    end

    def scan
      guestlist.each do |id|
        guests << Guest.new(id, self)
      end
      @guests.scan
      self
    end

    def guestlist
      list = Array.new
      table = session.exec!('qm list')
      lines = table.split("\n")
      lines.each do |line|
        if line =~ /^ *([0-9]{1,4}) */
          list << $1
        end
      end
      list
    end

    def localname
        session.exec!('hostname').chomp
    end

    def uptime
        session.exec!('uptime').chomp
    end

    def close
      disconnect
    end

    def disconnect
        session.close
    end

    def is_proxmox?
        output = session.exec!('qm list')
        (output =~ /VMID NAME/) ? true : false
    end

    def exec(cmd)
      session.exec!(cmd).chomp
    end


  end
end
