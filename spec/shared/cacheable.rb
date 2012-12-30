require 'spec_helper'

shared_examples :cacheable do
  let(:model) { described_class }

  describe 'ClassMethods' do
    let(:key) { 'cache_key' }
    let(:value) { 1 }

    describe '#cache_set' do
      subject { model.cache_set(key, value) }

      it { should == value }

      it 'should be stored cache' do
        model.cache_driver.get(key).should == value
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

      subject { model.cache_del(key) }

      it { should be_true }

      it 'should be deleted cache' do
        model.cache_get(key).should be_nil
      end
    end
  end
end
