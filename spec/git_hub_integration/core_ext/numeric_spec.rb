require "spec_helper"

RSpec.describe Numeric do
  it "should set the correct constant second calculations" do
    expect(Numeric::MINUTE_SECONDS).to eq(60)
    expect(Numeric::HOUR_SECONDS).to eq(60 * 60)
    expect(Numeric::DAY_SECONDS).to eq(60 * 60 * 24)
  end

  describe "#seconds" do
    it 'should just return the numeric' do
      expect(4.seconds).to eq 4
      expect(1.second).to eq 1
    end

    it 'should return the numeric' do
      expect(18.seconds).to be_a(Numeric)
    end
  end

  describe "#minutes" do
    it 'should return the number of seconds' do
      expect(1.minute).to eq Numeric::MINUTE_SECONDS
      expect(5.minutes).to eq(5 * Numeric::MINUTE_SECONDS)
    end

    it 'should return the numeric' do
      expect(18.minutes).to be_a(Numeric)
    end
  end

  describe "#hours" do
    it 'should return the number of seconds' do
      expect(1.hour).to eq Numeric::HOUR_SECONDS
      expect(5.hours).to eq(5 * Numeric::HOUR_SECONDS)
    end

    it 'should return the numeric' do
      expect(18.hours).to be_a(Numeric)
    end
  end

  describe "#days" do
    it 'should return the number of seconds' do
      expect(1.day).to eq Numeric::DAY_SECONDS
      expect(5.days).to eq(5 * Numeric::DAY_SECONDS)
    end

    it 'should return the numeric' do
      expect(18.days).to be_a(Numeric)
    end
  end

  describe "#from_now" do
    let(:dt) { Time.new(2021, 6, 24, 18, 0, 0, '-04:00') }

    it 'should return the future time with the second offset added' do
      Timecop.freeze(dt) do
        future_time = 33.seconds.from_now
        expected_time = Time.new(2021, 6, 24, 18, 0, 33, '-04:00')
        expect(future_time).to eq expected_time
      end
    end

    it 'should return the future time with the minute offset added' do
      Timecop.freeze(dt) do
        future_time = 33.minutes.from_now
        expected_time = Time.new(2021, 6, 24, 18, 33, 0, '-04:00')
        expect(future_time).to eq expected_time
      end
    end

    it 'should return the future time with the hour offset added' do
      Timecop.freeze(dt) do
        future_time = 2.hours.from_now
        expected_time = Time.new(2021, 6, 24, 20, 0, 0, '-04:00')
        expect(future_time).to eq expected_time
      end
    end

    it 'should return the future time with the day offset added' do
      Timecop.freeze(dt) do
        future_time = 2.days.from_now
        expected_time = Time.new(2021, 6, 26, 18, 0, 0, '-04:00')
        expect(future_time).to eq expected_time
      end
    end
  end
end
