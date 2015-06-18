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
        return ' 17:55:58 up  7:41,  3 users,  load average: 0.64, 0.33, 0.26'
      when 'qm list'
        return <<-EOT
          VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
           100 gwclient-2           running    1024              10.00 826679
           101 gwclient-socks       running    1024              32.00 95574
           102 vagrant              running    8192             128.00 179183
           103 Test-Debian-6-64     running    1024               6.00 186689
           104 API-Debian-6-64      running    512                5.00 221601
           105 API-Debian-6-32      running    512                5.00 222661
           106 API-Centos-6-32      running    512               32.00 235640
           107 Test-Centos-6-64     running    2048              32.00 237509
           108 Jenkins-Centos6-64   running    4096              64.00 266145
           109 git                  running    4096              40.00 760434
           300 VM 300               stopped    0                  4.00 0
        EOT
      when /qm config [0-9]{1,9}/
        return <<-EOT
          boot: ccn
          bootdisk: virtio0
          cores: 1
          description: 192.168.100.26%0A
          ide2: none,media=cdrom
          memory: 1024
          name: gwclient-2
          net0: e1000=76:E2:B3:E6:18:64,bridge=vmbr0
          numa: 0
          onboot: 1
          ostype: l26
          smbios1: uuid=77dbdeab-5382-4ddc-8c84-839dcfaf95a0
          sockets: 1
          virtio0: local:100/vm-100-disk-1.qcow2,format=qcow2,size=10G
        EOT
    end

  end

  def disconnect
    # ignore
  end

end

describe 'Host' do

  it 'should initialize and connect' do

    h = Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect
    expect(h).to be_an_instance_of(Quickmox::Host)
  end

  it 'should get local hostname' do
    expect(Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect.localname).to eq('host1')
  end

  it 'should get uptime' do
    expect(Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect.uptime)
        .to eq(' 17:55:58 up  7:41,  3 users,  load average: 0.64, 0.33, 0.26')
  end

  it 'should scan' do
    expect(Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect.scan.guests).to be_instance_of(Guestlist)
    expect(Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect.scan.guests).to_not be_empty
  end

  it 'should have guests data' do
    Host.new(hostname: '127.0.0.1', username: 'foo', password: 'bar').connect.scan.guests.each do |guest|
      expect(guest.id).to match(/[0-9]{1,9}/)
      expect(guest.scan.params).to be_an_instance_of(Hash)
      expect(guest.params).to_not be_empty
    end
  end

end