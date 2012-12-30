require 'spec_helper'

shared_examples :cacheable do
  let(:model) { described_class }

  before do
    3.times do
      model.create(
        string: Forgery::Basic.text,
        integer: rand(255),
        float: rand(3000).to_f / 10.0,
        bignum: (2 + rand(10)) ** 100,
        numeric: BigDecimal(rand(100).to_s),
        date: Date.today,
        datetime: DateTime.now,
        time: Time.now,
        bool: rand(2).odd?
      )
    end
  end

  describe 'ClassMethods' do
    let(:key) { 'cache_key' }
    let(:value) { 1 }

    describe '#cache_set' do
      subject(:cache_set) { model.cache_set(key, value) }

      it { should == value }

      it 'should be stored cache' do
        cache_set
        model.cache_driver.get("#{model.name}:#{key}").should == value
      end
    end

    describe '#cache_get' do
      before do
        model.cache_set(key, value)
      end

      subject { model.cache_get(key) }

      it { should == value }
    end

    describe '#cache_del' do
      before do
        model.cache_set(key, value)
      end

      subject(:cache_del) { model.cache_del(key) }

      it { should be_nil }

      it 'should be deleted cache' do
        cache_del
        model.cache_get("#{model.name}:#{key}").should be_nil
      end
    end

    describe '#cache_fetch' do
      it 'should call driver#fetch' do
        model.cache_driver.should_receive(:fetch).and_call_original
        model.cache_fetch('test') do
          2
        end
      end
    end
  end

  describe 'DatasetMethods' do
    describe '#all' do
      subject(:fetch_all) { model.all }

      it { should have(3).records }

      it 'should call .cache_fetch' do
        model.should_receive(:cache_fetch).and_return([])
        fetch_all
      end
    end

    describe '#first' do
      subject(:fetch_first) { model.first }

      it { should be_kind_of(model) }

      it 'should cfirst .cache_fetch' do
        model.should_receive(:cache_fetch).and_return([])
        fetch_first
      end
    end
  end

  describe 'InstanceMethods' do
  end
end
