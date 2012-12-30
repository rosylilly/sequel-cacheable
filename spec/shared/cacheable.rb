require 'spec_helper'

shared_examples :cacheable do
  let(:model) { described_class }

  before do
    model.cache_clear(:query)

    3.times do
      model.create(
        :string => Forgery::Basic.text,
        :integer => rand(255),
        :float => rand(3000).to_f / 10.0,
        :bignum => (2 + rand(10)) ** 100,
        :numeric => BigDecimal(rand(100).to_s),
        :date => Date.today,
        :datetime => DateTime.now,
        :time => Time.now,
        :bool => rand(2).odd?
      )
    end
  end

  describe 'ClassMethods' do
    let(:key) { 'cache_key' }
    let(:value) { model.first }

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
        model.cache_driver.should_receive(:fetch).at_least(1).times.and_call_original

        model.cache_fetch('test') do
          value
        end
      end
    end
  end

  describe 'DatasetMethods' do
    let(:dataset) { model.dataset }

    describe '#all' do
      subject(:fetch_all) { dataset.all }

      it { should have(3).records }

      it { should == model.all }

      it 'should store query cache' do
        expect { fetch_all }.to change { model.caches[:query].size }.from(0).to(1)
      end
    end

    describe '#first' do
      subject(:fetch_first) { dataset.first }

      it { should be_kind_of(model) }

      it 'should store query cache' do
        expect { fetch_first }.to change { model.caches[:query].size }.from(0).to(1)
      end
    end
  end

  describe 'InstanceMethods' do
    let(:instance) { model.first }

    describe '#after_initialize' do
      it 'should call #cache!' do
        model.any_instance.should_receive(:cache!)
        model.first
      end
    end

    describe '#after_update' do
      it 'should call #recache!' do
        instance.string = 'hoge'
        instance.should_receive(:recache!)
        instance.save
      end
    end

    describe '#destory' do
      it 'should call #uncache!' do
        instance.should_receive(:uncache!)
        instance.destroy
      end
    end

    describe '#delete' do
      it 'should call #uncache!' do
        instance.should_receive(:uncache!)
        instance.delete
      end
    end

    describe '#cache!' do
      it 'should call .cache_set' do
        instance = model.first
        model.should_receive(:cache_set).with(instance.id.to_s, instance)
        instance.cache!
      end
    end

    describe '#uncache!' do
      it 'should call .cache_del' do
        model.should_receive(:cache_del).at_least(1).times
        instance.uncache!
      end

      it 'should call .cache_clear(:query)' do
        model.should_receive(:cache_clear).with(:query)
        instance.uncache!
      end
    end

    describe '#recache!' do
      it 'should call #uncache! and #cache!' do
        instance.should_receive(:uncache!)
        instance.should_receive(:cache!)
        instance.recache!
      end
    end
  end
end
