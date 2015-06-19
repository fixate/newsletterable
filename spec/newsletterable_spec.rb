require 'spec_helper'

RSpec.describe Newsletterable do
	describe '.configuration' do
		it 'returns a configuration instance' do
			expect(described_class.configuration).to be_kind_of(Newsletterable::Configuration)
		end
	end

	describe 'default list resolver' do
		subject { described_class.configuration.list_resolver }

		it 'returns a list as an array' do
			expect(subject.call(nil, nil, 'test-list')).to eq(['test-list'])
		end

		it 'returns a list as an array from a list_name' do
			expect(subject.call(nil, 'test', { 'test' => ['list1', 'list2'] }))
				.to eq(['list1', 'list2'])
		end

		it 'returns a list from a lambda' do
			subscriber = double(:subscriber, list: '1234')
			procedure = proc do |sub|
				sub.list
			end
			expect(subject.call(subscriber, nil, procedure)).to eq(['1234'])
		end
	end
end
