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
      handle_exceptions { @session.connect }
      self
    end

    def rescan
      scan
    end

    def scan
      handle_exceptions do
        guestlist.each do |id|
          @guests << Guest.new(id, self)
        end
        @guests.scan
      end
      self
    end

    def guestlist
      list = String.new
      handle_exceptions do
        list = Array.new
        table = exec('qm list')
        lines = table.split("\n")
        lines.each do |line|
          if line =~ /^ *([0-9]{1,4}) */
            list << $1
          end
        end
      end
      list
    end

    def localname
      handle_exceptions { exec('hostname') }
    end

    def uptime
      handle_exceptions { exec('uptime') }
    end

    def close
      handle_exceptions { disconnect }
    end

    def disconnect
      handle_exceptions { session.close }
    end

    def is_proxmox?
        output = String.new
        handle_exceptions { output = exec('qm list') }
        (output =~ /VMID NAME/) ? true : false
    end

    def exec(cmd)
      handle_exceptions { session.exec!(cmd) }
    end

    private

    def handle_exceptions
      begin
        yield
      rescue => e
        raise HostError, "Exception in Quickmox::Host while handling host #{@session.host}: #{e}"
      end
    end

  end
end
