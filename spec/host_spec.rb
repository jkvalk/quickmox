require 'rspec'

describe 'Host' do

  before(:each) do
    @fake_ssh_transport = double(SSHTransport, host: '127.0.0.1')

    allow(@fake_ssh_transport).to receive(:close)
    allow(@fake_ssh_transport).to receive(:connect).and_return(@fake_ssh_transport)

    allow(@fake_ssh_transport).to receive(:exec!).with('hostname').and_return('host1')
    allow(@fake_ssh_transport).to receive(:exec!).with(/qm status [0-9]{1,9}/).and_return('status: running')
    allow(@fake_ssh_transport).to receive(:exec!).with(/qm (start|stop) [0-9]{1,9}/).and_return('')
    allow(@fake_ssh_transport).to receive(:exec!).with(/qm set ([0-9]{1,9}) (-[0-9a-z]{1,999}) (.*)/).and_return("update VM #{$1} #{$2} #{$3}")
    allow(@fake_ssh_transport).to receive(:exec!).with('uptime').and_return(' 17:55:58 up  7:41,  3 users,  load average: 0.64, 0.33, 0.26')
    allow(@fake_ssh_transport).to receive(:exec!).with('qm list').and_return(
                                      <<-EOT
                                                  VMID NAME                 STATUS     MEM(MB)    BOOTDISK(GB) PID
                                                   100 gwclient-2           running    1024              10.00 826679
                                                   101 gwclient-socks       running    1024              32.00 95574
                                                   300 VM 300               stopped    0                  4.00 0
                                  EOT
                                  )
    allow(@fake_ssh_transport).to receive(:exec!).with(/qm config [0-9]{1,9}/).and_return(
                                      <<-EOT
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
                                  )
    allow(SSHTransport).to receive(:new).and_return(@fake_ssh_transport)
  end


  it 'should initialize and connect' do
    expect(
        Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect
    ).to be_an_instance_of(Host)
  end


  it 'should get local hostname' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.localname).to eq('host1')
  end


  it 'should get uptime' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.uptime)
        .to eq(' 17:55:58 up  7:41,  3 users,  load average: 0.64, 0.33, 0.26')
  end

  it 'should scan' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.scan.guests).to be_instance_of(Guestlist)
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.scan.guests).to_not be_empty
  end

  it 'should have guests data' do
    Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.scan.guests.each do |guest|
      expect(guest.id).to match(/[0-9]{1,9}/)
      expect(guest.rescan.params).to be_an_instance_of(Hash)
      expect(guest.params).to_not be_empty
    end
  end


  it 'should show status' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
               .connect.scan.guests.first.status).to eq('running')
  end

  it 'should start and stop' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
               .connect.scan.guests.first.stop).to eq('')

    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
               .connect.scan.guests.first.start).to eq('')
  end

  it 'should set a parameter' do
    expect { Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
                 .connect.scan.guests.first.set_param('memory', '128') }.to_not raise_error
  end

  it 'should rescan' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
               .connect.rescan).to be_an_instance_of(Host)
  end

  it 'should get guest name' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar'))
               .connect.scan.guests.first.scan.name).to eq('gwclient-2')
  end

  it 'should disconnect' do
    Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.close
  end

  it 'should know if it is proxmox host' do
    expect(Host.new(SSHTransport.new('127.0.0.1', 'foo', 'bar')).connect.is_proxmox?).to eq(true)
  end

end