require "active_model"
require "active_support/concern"
require "active_support/core_ext"

require "newsletterable/version"
require "newsletterable/configuration"
require "newsletterable/errors"
require "newsletterable/model"
require "newsletterable/service"
require "newsletterable/subscriber"
require "newsletterable/worker"
require "newsletterable/orm_adapters/adapter"
require "newsletterable/railtie" if defined?(Rails)

module Newsletterable
	extend self
	@@lock = Mutex.new

	def configuration
		@@lock.synchronize do
			@@configuration ||= Configuration.new(defaults)
		end
	end

	def configure
		yield configuration
	end

  def self.eager_load!
    # No autoloads
  end

	private

	def defaults
		{
			worker: Newsletterable::Worker,
			list_resolver: default_list_resolver,
			old_email_getter: -> (subscriber) {
				if subscriber.respond_to?(:old_email)
					subscriber.old_email
				elsif subscriber.respond_to?(:email_was)
					subscriber.email_was
				else
					raise ConfigurationError, <<-TEXT, __FILE__, __LINE__ + 1
						Unable to retreive old email for update. Perhaps consider
						implementing 'old_email_getter' in your newsletterable initializer.

						e.g.
						config.old_email_getter = -> (user) do
							# Get the updated email address from your model
							user.email_before_update
						end
					TEXT
				end
			}
		}
	end

	def default_list_resolver
		-> (subscriber, list_name, lists) do
			result = case lists
			when String, Array
				lists
			when Hash
				lists[list_name]
			else
				if lists.respond_to?(:call)
					lists.call(subscriber)
				end
			end

			Array.wrap(result)
		end
	end
end
