module Newsletterable
	class Service
		attr_reader :subscriptionable

		def initialize(subscriptionable)
			@subscriptionable = subscriptionable
		end

		def subscribe(lists)
			lists.each do |list|
				subscription = orm_adapter.query_subscription({
					subscriptionable: subscriptionable,
					list: list
				}, true)

				if subscription.unsubscribed? || subscription.error?
					subscription.pending!
				end

				orm_adapter.save(subscription) unless subscription.subscribed?
			end
		end

		def unsubscribe(lists)
			lists.each do |list|
				subscription = orm_adapter.query_subscription(
					subscriptionable: subscriptionable,
					list: list
				)
				unless subscription.nil?
					subscription.unsubscribed!
					orm_adapter.save(subscription)
				end
			end
		end

		def update(lists, old_email)
			lists.each do |list|
				subscription = orm_adapter.query_subscription(
					subscriptionable: subscriptionable,
					list: list
				)

				if subscription.nil?
					raise RuntimeError, "No subscription to update for subscriptionable #{subscriptionable.id}."
				end

				subscription.out_of_date!
				subscription.old_email = old_email
				orm_adapter.save(subscription)
			end
		end

		private

		def orm_adapter
			@orm_adapter ||= OrmAdapters::Adapter.factory(Newsletterable.configuration.orm_adapter)
		end
	end
end
