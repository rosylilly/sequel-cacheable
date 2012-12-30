require 'spec_helper'

shared_examples 'cacheable' do
  describe 'ClassMethods' do
    describe '#cache_set' do
      let(:key) { 'cache_key' }
      let(:value) { 1 }
      subject { model.cache_set(key, value) }

      it { should be_true }
    end
  end
end
