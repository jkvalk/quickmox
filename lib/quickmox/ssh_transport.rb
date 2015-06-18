module Quickmox

  class SSHTransport

    attr_accessor :session

    def initialize(host, user, pass)
      @session = Net::SSH.start(host,
                                user,
                                password: pass,
                                auth_methods: %w(password),
                                number_of_password_prompts: 0,
                                timeout: 3)
    end

    def close
      session.close
    end

    def exec!(cmd)
      session.exec!(cmd).chomp
    end

  end
end
