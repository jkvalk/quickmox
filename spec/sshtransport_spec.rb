require 'rspec'

describe 'SSHTransport' do

  before do

    @fake_session = double(Net::SSH::Connection::Session)
    allow(Net::SSH).to receive(:start).and_return(@fake_session)

    allow(@fake_session).to receive(:exec!).and_return('output')
    allow(@fake_session).to receive(:close)

  end

  it 'should initialize and connect' do

    expect(SSHTransport.new('','','').connect).to be_an_instance_of(SSHTransport)
  end

  it 'should exec' do
    expect(SSHTransport.new('','','').connect.exec!('')).to eq('output')
  end

  it 'should close' do
    expect(SSHTransport.new('','','').connect.close).to eq(nil)
  end
end