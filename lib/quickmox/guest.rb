module Quickmox

  class Guest

    attr_accessor :host, :id, :params

    def initialize(id, host)
      @host = host
      @id = id
      @params = Hash.new
    end

    def status
      line = host.exec "qm status #{id}"
      (line =~ /status: (.*)/) ? $1.chomp : 'unknown'
    end

    def start
      host.exec "qm start #{id}"
    end

    def stop
      host.exec "qm stop #{id}"
    end

    def set_param(param, value)
      host.exec "qm set #{id} -#{param} #{value}"
    end

    def rescan
      scan
    end

    def name
      params[:name]
    end

    def scan
      host.exec("qm config #{id}").split("\n").each do |line|
        case line
          when /net0:.*=([0-9A-Fa-f:]{17}),/
            params[:mac] = $1
            params[:mac] = params[:mac].gsub(':', '').downcase
          when /cores: ([0-9]{1,3})/
            params[:cores] = $1
          when /bootdisk: (.*)/
            params[:bootdisk] = $1
          when /description: (.*)/
            params[:description] = $1
          when /memory: ([0-9]{1,6})/
            params[:memory] = $1
          when /name: (.*)/
            params[:name] = $1
          when /onboot: ([0-9])/
            params[:onboot] = $1
          when /(scsi|virtio|ide)[0-9]{1,3}: .*size=([0-9]{1,3}[MGTK])/
            params[:disk] = $2
        end
      end
      self
    end
  end
end
