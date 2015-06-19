require "rails"

module MandrillQueue
  class Railtie < Rails::Railtie # :nodoc:
    config.eager_load_namespaces << Newsletterable

    initializer "newsletterable.initialize" do |app|
			Newsletterable.configure do |config|
				if defined?(ActiveRecord)
					config.orm_adapter = :active_record
				elsif defined?(Mongoid)
					config.orm_adapter = :mongoid
				end
			end
    end
  end
end
