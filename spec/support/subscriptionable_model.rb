class SubscriptionableModel
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming
	extend ActiveModel::Callbacks
	define_model_callbacks :save, only: :after

	include Newsletterable::Model
	attr_accessor :id, :old_email, :list, :state

	def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
	end

	def my_worker
		Class.new do
			def perform_async(*args); end
		end.perform_async
	end

	def save!

	end
end
