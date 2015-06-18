require 'rspec'

class SSHTransport
  def initialize(host, user, pass)
    # ignore
  end

  def exec!(cmd)
    case cmd
      when 'hostname'
        return 'host1'
      when 'uptime'
        return '17:55:58 up  7:41,  3 users,  load average: 0.64, 0.33, 0.26'
    end

  end

  def disconnect
    # ignore
  end

end

describe 'Host' do

  it 'should pass' do

    h = Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar')
    h.connect
    p h.localname
  end

end