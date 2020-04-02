# ArtemisApi

This is a simple API wrapper for the [Artemis](https://artemisag.com/) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artemis_api'
```

If you want to ensure the most up to date version, you can also use the gem straight from the repository:

```ruby
gem 'artemis_api', :git => 'https://github.com/artemis-ag/artemis_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artemis_api

## Usage

#### Instantiating your Client

In order to use this gem, you will need to be set up as a developer in the Artemis Portal. If you're not, please contact Artemis CS in order to get that settled.

Once you have developer access, go to Settings and choose "OAuth 2.0 Applications" at the bottom of the sidebar to set up an application by entering the name and redirect URI you wish to use. You will then be provided with an application ID and a secret ID, which you will need in order to authenticate with Artemis.

The first step to actually using this gem is to instantiate an instance of `ArtemisApi::Client` and there are two different ways to do so depending on if you're handling OAuth in your own app or not.

If you intend to do a full OAuth flow, we recommend using the [OAuth2 gem](https://github.com/oauth-xx/oauth2). After authenticating with OAuth and generating your access token and refresh token, you can use them to instantiate your Client instance. You'll also need to pass in the `expires_at` for when your token will expire. That looks like this:

```ruby
options = {app_id: 'your_artemis_application_id',
           app_secret: 'your_artemis_secret_id',
           base_uri: 'https://portal.artemisag.com'}

client = ArtemisApi::Client.new(access_token: 'your_access_token',
                                refresh_token: 'your_refresh_token',
                                expires_at: token_expires_at,
                                options: options)
```

Instead of passing in options, you can set those values as ENV variables called `ENV['ARTEMIS_OAUTH_APP_ID']`, `ENV['ARTEMIS_OAUTH_APP_SECRET']` and `ENV['ARTEMIS_BASE_URI']`

They will be automatically detected and then you don't have to pass in any options:
```ruby
client = ArtemisApi::Client.new(access_token: 'your_access_token',
                                refresh_token: 'your_refresh_token',
                                expires_at: token_expires_at)
```

Alternatively, if you're working on a command line tool or otherwise not intending to implement a full OAuth flow, you can generate an authorization code directly and use this code to obtain an access token and a refresh token.
Do this by creating an OAuth application in your Artemis settings with `urn:ietf:wg:oauth:2.0:oob` as the callback url. Then, clicking the Authorize button directly on Artemis Portal beside it on your application show page will
provide you directly with an authorization code. Pass it into the Client instantiator like this. (The same rules apply about either passing in options or setting your ENV variables.)

```ruby
client = ArtemisApi::Client.new(auth_code: 'your_generated_authorization_code')
```

This authorization code is only valid for one use. If you want to keep connecting using the same authorization grant, you
need to save the values of `client.access_token`, `client.refresh_token` and `client.expires_at` and use them when
reinstantiating `client` in the future.

#### Requesting data from Artemis

Once you have a client instance, you can use it to request information from Artemis.

To get user information about the Artemis User that is associated with your application ID:
```ruby
client.current_user
```
Or alternatively, you can make the call directly to the User class:

```ruby
ArtemisApi::User.get_current(client: client)
```

(Please note that we use named parameters in most of our function calls.)

You can use either method to get a list of all Artemis Organizations or Facilities that you have access to:
```ruby
client.organizations
client.facilities

ArtemisApi::Organization.find_all(client: client)
ArtemisApi::Facility.find_all(client: client)
```

To get facility information about a single Artemis Organization or Facility that you have access to, by its Artemis ID:
```ruby
client.organization(1)
client.facility(2)

ArtemisApi::Organization.find(id: 1, client: client)
ArtemisApi::Facility.find(id: 2, client: client)
```

Other models are scoped by facility, so you have to include the Facility id in the call. (You can also get information about other Artemis Users besides your own account this way.)

To get all Users associated with the Facility with an ID of 2, again there are two methods. You can call directly to the User class, or you can query through a facility.
```ruby
client.facility(2).users

ArtemisApi::User.find_all(facility_id: 2, client: client)
```

To get a single User, with id 12, which must also be associated with Facility 2:
```ruby
client.facility(2).user(12)

ArtemisApi::User.find(id: 12, facility_id: 2, client: client)
```

You can get info about Batches, Zones, SeedingUnits, HarvestUnits and Subscriptions in the same manner. Here are a couple examples, but the syntax is all the same.
```ruby
client.facility(2).batches
client.facility(2).batch(22)

ArtemisApi::Batch.find_all(facility_id: 2, client: client)
ArtemisApi::Batch.find(id: 22, facility_id: 2, client: client)

client.facility(2).seeding_units
client.facility(2).seeding_unit(4)

ArtemisApi::SeedingUnit.find_all(facility_id: 2, client: client)
ArtemisApi::SeedingUnit.find(id: 4, facility_id: 2, client: client)
```

Completions, Harvests and Discards can be queried through a Batch object in a similar way. Again, you can also call directly to the class. Note that in the above examples, querying through facility or the class will give you the exact same results: that isn't true in this case. Querying through the batch will return only objects associated with that batch, while doing a `find_all` on the class will give you all objects associated with the entire facility.
```ruby
client.facility(2).batch(22).harvests
client.facility(2).batch(22).discards
client.facility(2).batch(22).completions

client.facility(2).batch(22).harvest(47)

ArtemisApi::Harvest.find_all(facility_id: 2, client: client)
ArtemisApi::Harvest.find(id: 47, facility_id: 2, client: client)
```

Additionally, Items are scoped by both Facility and Batch, so both are required even if you call directly to the Item class. There is also an optional `seeding_unit_id` param if you query through a batch.
```ruby
client.facility(2).batch(22).items
client.facility(2).batch(22).items(seeding_unit_id: 17)

ArtemisApi::Item.find_all(facility_id: 2, batch_id: 22, client: client)
```

Once you have queried info about a certain object, it will be stored in a hash called `objects` that exists on your active `client` object. Then, if you have to query the same object again, it can be pulled from that hash instead of doing another actual call to the API, to speed up performance. If you need to actually hit the API again for the most updated information, you can force the query like this:
```ruby
facility = ArtemisApi::Facility.find(id: 2, client: client, force: true)
```

Additionally, you can optionally include other models in your call that have a relationship with the model you're querying. They will then be included in the payload and added into the objects hash for your `client` for easier querying in the future.

```ruby
ArtemisApi::Facility.find(id: 2, client: client, include: "users")
ArtemisApi::Batch.find(id: 22, facility_id: 2, client: client, include: "completions")
```

We also support filtering on several models: Batch, Completion, Discard, Harvest, Zone, Item. It is another optional param and it expects a hash. Here's what that should look like.

```ruby
ArtemisApi::Batch.find_all(facility_id: 2, client: client, filters: {search: 'genovese basil'})
ArtemisApi::Batch.find_all(facility_id: 2, client: client, filters: {ids: [2, 4, 6, 11]})
ArtemisApi::Batch.find_all(facility_id: 2, client: client, filters: {date_type: 'seeded_at', date_window: "2019-10-31 17:06:42 -0400,2019-11-15 17:06:42 -0500"})

ArtemisApi::Completion.find_all(facility_id: 2, client: client, filters: {crop_batch_ids: [5]})
ArtemisApi::Harvest.find_all(facility_id: 2, client: client, filters: {crop_batch_ids: [5, 7]})
ArtemisApi::Discard.find_all(facility_id: 2, client: client, filters: {crop_batch_ids: [6, 7, 9]})
ArtemisApi::Zone.find_all(facility_id: 2, client: client, filters: {seeding_unit_id: 3})
ArtemisApi::Item.find_all(facility_id: 2, batch_id: 22, client: client, filters: {seeding_unit_id: 8})
```

Note that when you filter by ids or crop_batch_ids, you must pass in an array even if it only has one element.

Pagination is also supported on batches, and is also an optional param that expects a hash. We use the limit/offset method of pagination.

```ruby
ArtemisApi::Batch.find_all(facility_id: 2, client: client, page: {limit: 10, offset: 60})
```

The Artemis API is currently mainly read only, but we do support the creation of Subscriptions. These are used to set up webhooks that will make a callback to you whenever a Completion or Batch gets created or updated in the given facility. They require a `subject`, which can currently be either `completions` or `batches`, and a `destination`, which is the url that you want the callback to hit. There are two ways to make that call:

```ruby
ArtemisApi::Subscription.create(facility_id: 2,
                                subject: 'completions',
                                destination: 'https://test-app-url.artemisag.io/v1/webhook',
                                client: client)

facility.create_subscription(subject: 'completions', destination: 'https://test-app-url.artemisag.io/v1/webhook')
```

You can also delete one of your own Subscriptions. Trying to delete a Subscription that isn't associated with your user account will fail.

```ruby
ArtemisApi::Subscription.delete(id: 1, facility_id: 2, client: client)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artemis-ag/artemis_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArtemisApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/artemis-ag/artemis_api/blob/master/CODE_OF_CONDUCT.md).
