module Newsletterable
	module OrmAdapters
		class TestOrmAdapter < Adapter
			cattr_writer :query_subscription

			def query_subscription(query, initialize = false)
				record = @@query_subscription
				if initialize
					record ||= SubscriptionableModel.new(state: :pending)
				end
				record
			end

			def save(record)
				record.save!
			end
		end
	end
end
