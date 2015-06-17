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

    def initialize(opts = {})
      @hostname = opts[:hostname]
      @username = opts[:username]
      @password = opts[:password]
      begin
        @ip = Resolv.getaddress(@hostname)
      rescue => e
        @ip = String.new
      end
      @guests = Guestlist.new
    end

    def connect
      begin
        @session = Net::SSH.start(hostname,
                                  username,
                                  password: password,
                                  auth_methods: %w(password),
                                  number_of_password_prompts: 0,
                                  timeout: 3)

      rescue => e
        raise HostError, "Warning: exception while connecting to host #{hostname}: #{e}"
      end
      self
    end

    def rescan
      scan
    end

    def scan
      guestlist.each do |id|
        @guests << Guest.new(id, self)
      end
      self
    end

    def guestlist
      list = Array.new
      table = handle_exceptions { session.exec!('qm list') }
      lines = table.split("\n")
      lines.each do |line|
        if line =~ /^ *([0-9]{1,4}) */
          list << $1
        end
      end
      list
    end

    def localname
      handle_exceptions do
        session.exec!('hostname').chomp
      end
    end

    def uptime
      handle_exceptions do
        session.exec!('uptime').chomp
      end
    end

    def close
      disconnect
    end

    def disconnect
      begin
        session.close
      rescue => e
        raise HostError, "Warning: exception while disconnecting from host #{hostname}: #{e.to_s}"
      end
    end

    def is_proxmox?
      handle_exceptions do
        output = session.exec!('qm list')
        (output =~ /VMID NAME/) ? true : false
      end
    end

    def exec(cmd)
      handle_exceptions do
        return session.exec!(cmd).chomp
      end
    end

    private
    def handle_exceptions
      begin
        yield
      rescue => e
        raise HostError, "Exception while talking to host #{hostname}: #{e.to_s}"
      end
    end
  end
end
