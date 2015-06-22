module Newsletterable
	module Model
    extend ActiveSupport::Concern

    included do
			Newsletterable.configuration.subscriptions_model = self

			define_newsletterable_state_methods(self)
			define_newsletterable_callbacks(self)
    end

		def email
			subscribable.nil? ? self.old_email : subscribable.email
		end

		def enqueue_subscription
			worker = Newsletterable.configuration.worker
			case worker
			when Symbol, String
				# Get worker from method in model
				self.send(worker)
			else
				# Get worker from lambda function
				if worker.respond_to?(:call)
					worker.call(self.id)
				# worker is already a Worker class, call perform_async
				# TODO: should we require perform_async, make it configurable or make this an adapter
				elsif worker.respond_to?(:perform_async)
					worker.perform_async(self.id)
				else
					raise ConfigurationError, "config.worker is nil or invalid."
				end
			end
		end

		module ClassMethods
			def define_newsletterable_callbacks(klass)
				klass.class_eval do
					opts =[:enqueue_subscription, {
						if: proc { |n| !n.subscribed? },
						on: [:create, :update]
					}]

					if respond_to?(:after_commit)
						after_commit(*opts)
					else
						after_save(*opts)
					end
				end
			end

			def define_newsletterable_state_methods(klass)
				%i{ pending subscribed unsubscribed out_of_date error }.each do |state|
					klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
						def #{state}!
							self.state = '#{state}'
						end

						def #{state}?
							self.state.to_s == '#{state}'
						end
					RUBY
				end
			end
		end
	end
end
