require 'rspec'

describe Guestlist do

  before do
    @fake_guest1 = instance_double(Guest, id: '100', scan: @fake_guest1)
    @fake_guest2 = instance_double(Guest, id: '200', scan: @fake_guest2)

    @guestlist = Guestlist.new << @fake_guest1 << @fake_guest2
  end

  it 'should find' do
    # bullshit
    expect(@guestlist.find(100).id).to eq('100')
    expect(@guestlist.find(200).id).to eq('200')

  end

  it 'should scan' do
    expect(@guestlist.scan).to be_a_kind_of(Guestlist)
  end
end