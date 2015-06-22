require 'mailchimp'

module Newsletterable
	module Worker
		extend ActiveSupport::Concern

		def perform(subscription_id)
			@subscription = orm_adapter.query_subscription(id: subscription_id)

			if @subscription.nil?
				logger.warn "No subscription with id #{subscription_id} exists. Ignoring."
			else
				process
			end
		end

		def process
			logger.info "Processing mailing list subscription for #{@subscription.email}..."
			logger.debug "Status: [#{@subscription.state}]"

			case @subscription.state.to_sym
			when :pending || :error
				logger.info "Subscribing #{@subscription.email} to '#{@subscription.list}' list"
				logger.info "Trying to subscribe after previous error!" if @subscription.error?
				add(@subscription)
				@subscription.subscribed!
				@subscription.save!
			when :unsubscribed
				logger.info "Unsubscribing #{@subscription.email} from '#{@subscription.list}' list"
				remove(@subscription)
				@subscription.destroy!
			when :out_of_date
				logger.info "Updating subscription for #{@subscription.email}"
				update(@subscription)
				@subscription.old_email = nil
				@subscription.subscribed!
				@subscription.save!
			end

		rescue Mailchimp::Error => ex
			logger.error "#{@subscription.email}: #{ex.message || 'Unknown error.'}"
			@subscription.error!
			@subscription.save
			raise
		end

		private

		def orm_adapter
			@orm_adapter ||= OrmAdapters::Adapter.factory(Newsletterable.configuration.orm_adapter)
		end

		def mailchimp
      @mailchimp_api ||= Mailchimp::API.new(Newsletterable.configuration.api_key)
		end

		def add(subscription)
			mailchimp.lists.subscribe(subscription.list, { email: subscription.email })
		rescue Mailchimp::ListAlreadySubscribedError
			logger.warn "#{subscription.email} already subscribed to '#{subscription.list}'."
		end

		def remove(subscription)
			mailchimp.lists.unsubscribe(subscription.list, { email: subscription.email })
		rescue Mailchimp::ListNotSubscribedError
			logger.warn "#{subscription.email} is not subscribed to '#{subscription.list}'."
		end

		def update(subscription)
			raise UpdateError, "old_email required to update subscription for subscription #{subscription.id}." if subscription.old_email.nil?
			mailchimp.lists.subscribe(subscription.list, { email: subscription.old_email }, { 'new-email' => subscription.email }, 'html', true, true)
		end
	end
end
