module Newsletterable
	module Subscriber
		extend ActiveSupport::Concern

		included do
			class_eval %(
				class << self; attr_accessor :__newsletterable_options; end
			)
		end

		def subscription_service
			@subscription_service ||= Service.new(self)
		end

		def manage_subscription(list_name)
			field = field_for(list_name)
			list_ids = resolve_list(list_name)

			if send(field)
				subscription_service.subscribe(list_ids)
			else
				subscription_service.unsubscribe(list_ids)
			end
		end

		def resolve_list(list_name)
			options = options_for(list_name)
			lists = options[:lists] || Newsletterable.configuration.default_lists

			resolver = options[:resolver] || Newsletterable.configuration.list_resolver

			if resolver.is_a?(Symbol)
				self.send(resolver, list_name, lists)
			elsif resolver.respond_to?(:call)
				resolver.call(self, list_name, lists)
			else
				raise ConfigurationError, 'Newsletterable resolver should be a Symbol or callable.'
			end
		end

		def update_subscription(list_name)
			old_email = email_was

			yield

			list_ids = resolve_list(list_name)
			subscription_service.update(list_ids, old_email)
		end

		def remove_subscription(list_name)
			list_ids = resolve_list(list_name)
			subscription_service.unsubscribe(list_ids)
		end

		def options_for(list_name)
			self.class.__newsletterable_options[list_name]
		end

		def field_for(list_name)
			if options = options_for(list_name)
				options[:field]
			else
				nil
			end
		end

		module ClassMethods

			def subscribe_on(list_name, options = {})
				field = options[:field] || list_name

				self.__newsletterable_options ||= {}
				self.__newsletterable_options[list_name] = options.merge(field: field)

				after_save     -> { manage_subscription(list_name) }, if: :"#{field}_changed?"
				around_update  -> { update_subscription(list_name) }, if: -> { send(:"#{field}?") && email_changed? }
				unless options[:unsubscribe_on_destroy]
					before_destroy -> { remove_subscription(list_name) }, if: :"#{field}?"
				end
			end

		end
	end
end
