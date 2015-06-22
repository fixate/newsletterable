class SubscriberModel
	include ActiveModel::Validations
	include ActiveModel::Conversion
	extend ActiveModel::Naming
	extend ActiveModel::Callbacks
	define_model_callbacks :save, only: :after
	define_model_callbacks :update, only: :around
	define_model_callbacks :destroy, only: :before

	include Newsletterable::Subscriber

	attr_accessor :email, :newsletter, :everyone

	subscribe_on :newsletter
	subscribe_on :everyone

	def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
	end

  def persisted?
    false
  end
end
