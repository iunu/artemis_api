# ArtemisApi

This is a simple API wrapper for the [Artemis](https://artemisag.com/) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'artemis_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install artemis_api

## Usage

In order to use this gem, you will need to be set up as a developer in the Artemis Portal. If you're not, please contact Artemis CS in order to get that settled.

Once you have developer access, go to Settings and choose "OAuth 2.0 Applications" at the bottom of the sidebar to set up an application by entering the name and redirect URI you wish to use. You will then be provided with an application ID and a secret ID, which you will need in order to authenticate with Artemis.

(Please note that this gem doesn't currently handle OAuth. You will need to do that on your own in order to generate your access token and refresh token. We recommend using the [OAuth2 gem](https://github.com/oauth-xx/oauth2). You'll also need to pass in the `expires_at` for when your token will exipire.)

Once you have all this info, the first step to actually using this gem is to instantiate an instance of `ArtemisApi::Client` - which requires an access token, a refresh token,

```ruby
options = {app_id: 'your_artemis_application_id',
           app_secret: 'your_artemis_secret_id',
           base_uri: 'https://portal.artemisag.com'}

client = ArtemisApi::Client.new('your_access_token', 'your_refresh_token', token_expires_at, options)
```

Alternatively, instead of passing in options, you can set those values as ENV variables called `ENV['ARTEMIS_OAUTH_APP_ID']`, `ENV['ARTEMIS_OAUTH_APP_SECRET']` and `ENV['ARTEMIS_BASE_URI']`

They will be automatically detected and then you don't have to pass in any options:
```ruby
client = ArtemisApi::Client.new('your_access_token', 'your_refresh_token', token_expires_at)
```

Once you have a client instance, you can use it to request information from Artemis.

To get user information about the Artemis User that is associated with your application ID:
```ruby
ArtemisApi::User.get_current(client)
```

To get a list of all Artemis Organizations or Facilities that you have access to:
```ruby
ArtemisApi::Organization.find_all(client)
ArtemisApi::Facility.find_all(client)
```

To get facility information about a single Artemis Organization or Facility that you have access to, by its Artemis ID:
```ruby
ArtemisApi::Organization.find(1, client)
ArtemisApi::Facility.find(2, client)
```

Other models are scoped by facility, so you have to include the Facility id in the call. (You can also get information about other Artemis Users besides your own account this way.)

To get all Users associated with the Facility with an ID of 2:
```ruby
ArtemisApi::User.find_all(2, client)
```

To get a single User, with id 12, which must also be associated with Facility 2:
```ruby
ArtemisApi::User.find(12, 2, client)
```

You can get info about Batches, Zones, Completions, Harvests, Discards, SeedingUnits and HarvestUnits in a similar manner. Here are some examples, but the syntax is the same for all of those models:
```ruby
ArtemisApi::Batch.find_all(2, client)
ArtemisApi::Batch.find(22, 2, client)

ArtemisApi::Zone.find_all(2, client)
ArtemisApi::Zone.find(4, 2, client)

ArtemisApi::Completion.find_all(2, client)
ArtemisApi::Completion.find(30, 2, client)

ArtemisApi::SeedingUnit.find_all(2, client)
ArtemisApi::SeedingUnit.find(17, 2, client)
```

Additionally, Items are scoped by both Facility and Batch, and they also have an optional seeding_unit_id param. To get all Items, you must pass in both the Facility and Batch id:
```ruby
ArtemisApi::Item.find_all(2, 22, client, seeding_unit_id: 17)
```

If you have a Facility object, you can also get zones and batches that are associated with it.

And if you have a Batch object, you can get all the Completions, Items, Harvests and Discards that are associated with it. (Items can still accept an optional seeding_unit_id.)
```ruby
facility = ArtemisApi::Facility.find(2, client)

facility.zones
facility.find_zone(4)

facility.batches
batch = facility.find_batch(22)

batch.completions
batch.harvests
batch.discards
batch.items(seeding_unit_id: 17)
```

Once you have queried info about a certain object, it will be stored in a hash called `objects` that exists on your active `client` object. Then, if you have to query the same object again, it can be pulled from that hash instead of doing another actual call to the API, to speed up performance. If you need to actually hit the API again for the most updated information, you can force the query like this:
```ruby
facility = ArtemisApi::Facility.find(2, client, force: true)
```

Additionally, you can optionally include other models in your call that have a relationship with the model you're querying. They will then be included in the payload and added into the objects hash for your `client` for easier querying in the future.

```ruby
ArtemisApi::Facility.find(2, client, include: "users")
ArtemisApi::Batch.find(22, 2, client, include: "completions")
```

We also support filtering on the Batch and Completion models. It is another optional param and it expects a hash. Here's what that should look like.

```ruby
ArtemisApi::Batch.find_all(facility_id, client, filters: {view: 'all_batches', search: 'genovese basil'})
ArtemisApi::Batch.find_all(facility_id, client, filters: {ids: [2, 4, 6, 11]})
ArtemisApi::Completion.find_all(facility_id, client, filters: {crop_batch_ids: [5]})
```

Note that when you filter by ids or crop_batch_ids, you must pass in an array even if it only has one element.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/artemis-ag/artemis_api. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArtemisApi project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/artemis-ag/artemis_api/blob/master/CODE_OF_CONDUCT.md).
