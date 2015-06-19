require 'spec_helper'

RSpec.describe Newsletterable::Subscriber do
	subject { SubscriberModel.new }
	before do
		Newsletterable.configuration.default_lists = {
			newsletter: 'nwsltr',
			everyone: 'evyone'
		}
	end

	describe '#subscription_service' do
		it 'returns a SubscriptionService instance' do
			expect(subject.subscription_service).to be_kind_of(Newsletterable::Service)
		end
	end

	describe '#manage_subscription' do
		let(:subscription_service) { double(:subscription_service) }

		before do
			allow(subject).to receive(:subscription_service).and_return(subscription_service)
		end

		it 'subscribes to list' do
			subject.newsletter = true
			expect(subscription_service).to receive(:subscribe).with(['nwsltr'])
			subject.manage_subscription(:newsletter)
		end

		it 'unsubscribes from list' do
			subject.newsletter = false
			expect(subscription_service).to receive(:unsubscribe).with(['nwsltr'])
			subject.manage_subscription(:newsletter)
		end
	end
end

