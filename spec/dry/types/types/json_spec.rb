# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal do
  describe 'json.nil' do
    subject(:type) { Dry::Types['json.nil'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'foo', %w(foo)
    ]

    it 'coerces empty string to nil' do
      expect(type['']).to be(nil)
    end
  end

  describe 'json.date' do
    subject(:type) { Dry::Types['json.date'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'not-a-date'
    ]

    it 'coerces to a date' do
      expect(type['2015-11-26']).to eql(Date.new(2015, 11, 26))
    end
  end

  describe 'json.date_time' do
    subject(:type) { Dry::Types['json.date_time'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'not-a-date-time'
    ]

    it 'coerces to a date time' do
      expect(type['2015-11-26 12:00:00']).to eql(DateTime.new(2015, 11, 26, 12))
    end
  end

  describe 'json.time' do
    subject(:type) { Dry::Types['json.time'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'not-a-time'
    ]

    it 'coerces to a time' do
      expect(type['2015-11-26 12:00:00']).to eql(Time.new(2015, 11, 26, 12))
    end
  end

  describe 'json.decimal' do
    subject(:type) { Dry::Types['json.decimal'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, nil, '', 'not-a-decimal'
    ]

    it 'coerces strings to a decimal' do
      expect(type['3.12']).to eql(BigDecimal('3.12'))
    end

    it 'coerces floats to a decimal' do
      expect(type[3.12]).to eql(BigDecimal('3.12'))
    end
  end

  describe 'json.array' do
    subject(:type) { Dry::Types['json.array'].of(Dry::Types['nominal.integer']) }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'not-an-array'
    ]
  end

  describe 'json.hash' do
    subject(:type) { Dry::Types['json.hash'].schema(age: Dry::Types['nominal.integer']) }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'not-a-hash'
    ]
  end
end
