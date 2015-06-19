module Newsletterable
	module OrmAdapters
		class Mongoid < ActiveRecord
			def save(record)
				record.with(safe: true).save!
			end
		end
	end
end
