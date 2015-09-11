module Newsletterable
	class Configuration
		attr_accessor :api_key, :default_lists, :subscriptions_model, :worker,
			:list_resolver, :orm_adapter, :old_email_getter

		def initialize(attrs = {})
			attrs.each do |k, v|
				send(:"#{k}=", v)
			end
		end
	end
end
