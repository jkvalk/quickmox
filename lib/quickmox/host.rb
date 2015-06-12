require 'net/ssh'
require 'ap'
require 'resolv'

module Quickmox

# This class represents a SSH server host. It may or may not be
# connected to a Proxmox server. If it's not, proxmox specific 
# methods like guests(), guest_params() etc. will return empty
# data structures.
  class Host

    class HostError < StandardError
    end

    attr_accessor :hostname, :username, :password, :ip, :session

    # Initialize Host object
    # * +hostname:+
    # * +username:+
    # * +password:+
    #    h = Host.new(hostname:"10.0.0.1", username:"root", password:"qwerty123")
    def initialize(opts  = {})
      @hostname = opts[:hostname]
      @username = opts[:username]
      @password = opts[:password]
      begin
        @ip = Resolv.getaddress(@hostname)
      rescue => e
        @ip = ''
      end
    end

    # Make SSH connection and log in.
    def connect
      begin
        @session = Net::SSH.start(hostname,
                                  username,
                                  password: password,
                                  auth_methods: %w(password),
                                  number_of_password_prompts: 0,
                                  timeout: 3)

      rescue => e
        raise HostError, "Warning: exception while connecting to host #{hostname}: #{e.to_s}"
      end
      self
    end

    # Returns local hostname obtained by the Unix 'hostname' command
    def localname
      handle_exceptions do
        session.exec!('hostname').chomp
      end
    end

    # Returns host uptime
    def uptime
      handle_exceptions do
        session.exec!('uptime').chomp
      end
    end

    # Disconnects the SSH session
    def disconnect
      begin
        session.close
      rescue => e
        raise HostError, "Warning: exception while disconnecting from host #{hostname}: #{e.to_s}"
      end
    end

    # Checks if host responds to 'qm' commands
    def is_proxmox?
      handle_exceptions do
        output = session.exec!('qm list')
        (output =~ /VMID NAME/) ? true : false
      end
    end

    # Returns guest status (running/stopped/NA)
    # * +guest_id+ numeric ID of the guest
    def guest_status(guest_id)
      status = ''
      handle_exceptions do
        status = session.exec!("qm status #{guest_id}")
      end
      if status =~ /running/
        'running'
      elsif status =~ /stopped/
        'stopped'
      else
        'N/A'
      end
    end

    # Returns a hash of guest parameters
    # * +guest_id+ numeric ID of the guest
    #    h = guest_params(100)
    #    h = guest_params("101")
    def guest_params(guest_id)
      params = {}
      handle_exceptions do
        session.exec!("qm config #{guest_id}").split("\n").each do |line|
          if line =~ /net0:.*=([0-9A-Fa-f:]{17}),/
            params['mac'] = $1
            params['mac'].gsub!(':', '').downcase!
          elsif line =~ /cores: ([0-9]{1,3})/
            params['cores'] = $1
          elsif line =~ /bootdisk: (.*)/
            params['bootdisk'] = $1
          elsif line =~ /description: (.*)/
            params['description'] = $1
          elsif line =~ /memory: ([0-9]{1,6})/
            params['memory'] = $1
          elsif line =~ /name: (.*)/
            params['name'] = $1
          elsif line =~ /onboot: ([0-9])/
            params['onboot'] = $1
          elsif line =~ /(scsi|virtio|ide)[0-9]{1,3}: .*size=([0-9]{1,3}[MGTK])/
            params['disk'] = $2
          end
        end
      end
      params
    end

    # Returns an array of guest IDs on this host
    def guests
      guests = []
      table = handle_exceptions { session.exec!('qm list') }
      lines = table.split("\n")
      lines.each do |line|
        if line =~ /^ *([0-9]{1,4}) */
          guests << $1
        end
      end
      guests
    end

    # Wrapper method to rescue SSH/connection exceptions
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
