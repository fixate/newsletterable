module Newsletterable
	module OrmAdapters
		class ActiveRecord < Adapter
			def query_subscription(query, initialize = false)
				scope = subscriptions_model.where(query)

				if initialize
					scope.first_or_initialize do |s|
						s.pending!
					end
				else
					scope.first
				end
			end

			def save(record)
				record.save!
			end
		end
	end
end
