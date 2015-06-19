require 'newsletterable/orm_adapters/active_model'

module Newsletterable
	module OrmAdapters
		class Mongoid < ActiveModel
			def save(record)
				record.with(safe: true).save!
			end
		end
	end
end
