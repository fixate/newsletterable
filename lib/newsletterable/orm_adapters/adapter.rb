module Newsletterable
	module OrmAdapters
		class Adapter

			def self.factory(name)
				klass = "Newsletterable::OrmAdapters::#{name.to_s.camelize}"
				unless defined?(klass)
					require "newsletterable/orm_adapters/#{name}"
				end
				klass.constantize.new
			end

			protected

			def subscriptions_model
				Newsletterable.configuration.subscriptions_model
			end
		end
	end
end
