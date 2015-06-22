# Newsletterable

Keep mailing list subscriptions in sync with your
ActiveRecord or Mongoid (ActiveModel) models.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'newsletterable'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install newsletterable

## Usage

Your initializer:


```ruby
Newsletterable.configure do |config|
	# Mailchimp API key
	config.api_key = ENV['api_key']

	# Default lists
	config.default_lists = {
		newsletter: '123abc',
		everyone: 'cba321'
	}

	# Specify worker class or custom callback for enqueuing to your worker.
	# Workers usually include Newsletterable::Worker (defines the perform method)
	config.worker = MyWorker
	# or define a callable which will enqueue anyway you like, or synchonously
	config.worker = lambda { |id| SleepyWorker.perform_async('NewsletterTask', id.to_s) }
end
```

Your subscriber model e.g User class
Must respond_to `email` (TODO: make this configurable)

```ruby
class User < ActiveRecord::Base
	include Newsletterable::Subscriber

	has_many :newsletter_subscriptions, as: :subscribable

	# Boolean fields `newsletter` and `everyone`
	subscribe_on :newsletter
	# will unsubscribe if the subscriber class is destroyed
	subscribe_on :everyone, unsubscribe_on_destroy: true
end
```

Your Subscription model (each row is a subscription to a mailchimp list)
Here using mongoid so that we can easier see the required methods/fields.

```ruby
class NewsletterSubscription
	include Mongoid::Document
	include Newsletterable::Model

	# This must be an association to the subscribable object
	belongs_to :subscribable, polymorphic: true

	# Used to store old email addresses when object is destroyed or email updated
	field :old_email, type: String
	# List id of suibscription
	field :list, type: String
	# Either pending subscribed unsubscribed out_of_date or error
	field :state, type: String
end

```

Add a worker (using anything you like)

```ruby

class MyWorker
	include Sidekiq::Worker
	include Newsletterable::Worker

	sidekiq_options ....
end
```

## Contributing

1. Fork it ( https://github.com/fixate/newsletterable/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
