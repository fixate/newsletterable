require 'spec_helper'

RSpec.describe Newsletterable::Model do
	subject { Newsletterable.configuration.subscriptions_model.new }

	describe '.define_newsletterable_callbacks' do
		pending 'Test define_newsletterable_callbacks'
	end

	describe 'State methods' do
		%i{ pending subscribed unsubscribed out_of_date error }.each do |state|
			it { is_expected.to respond_to(:"#{state}!") }
			it { is_expected.to respond_to(:"#{state}?") }

			context 'setters' do
				it 'sets the state' do
					subject.send("#{state}!")
					expect(subject).to send("be_#{state}")
				end
			end

			context 'conditionals' do
				it 'returns true if state is set' do
					subject.state = state
					expect(subject.send("#{state}?")).to be(true)
				end
			end
		end
	end

	describe '#enqueue_subscription' do
		context 'symbol or string worker' do
			before { Newsletterable.configuration.worker = :my_worker }

			it 'calls the method on the model' do
				expect(subject).to receive(:my_worker).exactly(1).times
				subject.enqueue_subscription
			end
		end

		context 'lambda' do
			let(:worker) { double(:worker) }
			before { Newsletterable.configuration.worker = lambda { |id| worker.do_something(id) } }
			before { subject.id = 123 }

			it 'class the lambda function' do
				expect(worker).to receive(:do_something).with(123).exactly(1).times
				subject.enqueue_subscription
			end
		end

		context 'worker class' do
			let(:worker) { double(:worker, perform_async: true) }
			before { Newsletterable.configuration.worker = worker }
			before { subject.id = 123 }

			it 'class the lambda function' do
				expect(worker).to receive(:perform_async).with(123).exactly(1).times
				subject.enqueue_subscription
			end
		end

		context 'invalid' do
			let(:worker) { double(:worker) }
			before { Newsletterable.configuration.worker = worker }

			it 'class the lambda function' do
				expect {
					subject.enqueue_subscription
				}.to raise_error(Newsletterable::ConfigurationError)
			end
		end

	end
end

