require 'newsletterable/orm_adapters/active_model'

module Newsletterable
	module OrmAdapters
		class Mongoid < ActiveModel
			def query_subscription(query, initialize = true)
				# Work around for https://github.com/mongoid/mongoid/issues/4101
				if initialize && query[:subscribable]
					subscribable = query.delete(:subscribable)
					query[:subscribable_id] = subscribable.id
					query[:subscribable_type] = subscribable.class.to_s
				end

				super(query, initialize)
			end

			def save(record)
				record.with(safe: true).save!
			end
		end
	end
end
