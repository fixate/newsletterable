require 'spec_helper'

RSpec.describe Newsletterable::Service do
	let(:subscriptionable) { double(:subscriptionable) }
	let(:subscription) { double(:subscription) }

	subject { described_class.new(subscriptionable) }

	before do
		Newsletterable.configure do |config|
			# config.subscriptions_model = MailSubscription
			config.orm_adapter = :test_orm_adapter
		end

		described_class.send(:public, :orm_adapter)
	end

	describe '#subscribe' do
		it 'saves a subscription for each list' do
			expect(subject.orm_adapter).to receive(:save).exactly(2).times
			subject.subscribe(%w[ 123 234 ])
		end
	end

	describe '#unsubscribe' do
		before do
			Newsletterable::OrmAdapters::TestOrmAdapter.query_subscription =
				subscription

			allow(subscription).to receive(:save!)
		end

		after do
			Newsletterable::OrmAdapters::TestOrmAdapter.query_subscription = nil
		end

		it 'sets to unsubscribed' do
			expect(subscription).to receive(:unsubscribed!)
			subject.unsubscribe(%w[ 123 ])
		end
	end

	describe '#update' do
		before do
			Newsletterable::OrmAdapters::TestOrmAdapter.query_subscription = subscription
			allow(subscription).to receive(:save!)
		end

		after do
			Newsletterable::OrmAdapters::TestOrmAdapter.query_subscription = nil
		end

		it 'sets to out_of_date' do
			allow(subscription).to receive(:old_email=)
			expect(subscription).to receive(:out_of_date!)
			subject.update([123], 'test')
		end

		it 'sets old email' do
			expect(subscription).to receive(:old_email=).with('test')
			allow(subscription).to receive(:out_of_date!)
			subject.update([123], 'test')
		end
	end
end

