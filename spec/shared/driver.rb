shared_examples :driver do
  let(:pack_lib) { MessagePack }
  subject(:driver) { described_class.new(store, pack_lib) }

  let(:key) { 'cache_key' }
  let(:val) { 100 }

  describe '#set' do
    subject { driver.set(key, val) }

    it { should == val }

    it 'should be stored in cache' do
      driver.set(key, val)
      store.get(key).should_not be_nil
    end

    context 'with expire' do
      subject { driver.set(key, val, -1) }

      it 'should be expired cache' do
        store.get(key).should be_nil
      end
    end
  end

  describe '#get' do
    before do
      driver.set(key, val)
    end

    let(:get_key) { key }

    subject { driver.get(get_key) }

    context 'be found key' do
      it { should == val }
    end

    context 'be not found key' do
      let(:get_key) { 'not_found' }

      it { should be_nil }
    end
  end

  describe '#del' do
    before do
      driver.set(key, val)
    end

    subject(:del_method) { driver.del(key) }

    it { should be_nil }

    it 'should be deleted cache' do
      store.get(key).should_not be_nil
      del_method
      store.get(key).should be_nil
    end
  end

  describe '#expire' do
    before do
      driver.set(key, val)
    end

    it 'should be expired cache' do
      store.get(key).should_not be_nil
      driver.expire(key, -1)
      store.get(key).should be_nil
    end
  end

  describe '#fetch' do
    subject(:fetch) do
      driver.fetch(key) { val }
    end

    context 'be found key' do
      before do
        driver.set(key, val)
      end

      it { should == val }

      it 'should not call #set' do
        store.should_not_receive(:set)
        fetch
      end
    end

    context 'be not found key' do
      it { should == val }

      it 'should call #set' do
        store.should_receive(:set).and_call_original
        fetch
      end
    end
  end
end
