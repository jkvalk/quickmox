module Quickmox

  class SSHTransport

    class SSHTransportError < StandardError
    end

    attr_accessor :session, :host, :user, :pass

    def initialize(host, user, pass)
      @host = host
      @user = user
      @pass = pass
    end

    def connect
      handle_exceptions do
        @session = Net::SSH.start(host,
                                  user,
                                  password: pass,
                                  auth_methods: %w(password),
                                  number_of_password_prompts: 0,
                                  timeout: 3,
                                  paranoid: false)
      end
      self
    end

    def close
      handle_exceptions do
        session.close
      end
    end

    def exec!(cmd)
      handle_exceptions do
        session.exec!(cmd).to_s.chomp
      end
    end

    private

    def handle_exceptions
      begin
        yield
      rescue => e
        raise SSHTransportError, "Exception while talking to host #{host}: #{e}"
      end
    end

  end
end
