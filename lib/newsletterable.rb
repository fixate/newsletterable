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
			list_resolver: default_list_resolver
		}
	end

	def default_list_resolver
		proc do |subscriber, list_name, lists|
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
