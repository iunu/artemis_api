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

(Please note that this gem doesn't currently handle OAuth. You will need to do that on your own in order to generate your access token and refresh token. We recommend using the [OAuth2 gem](https://github.com/oauth-xx/oauth2))

Once you have all this info, the first step to actually using this gem is to instantiate an instance of `ArtemisApi::Client` - which requires an access token, a refresh token,

```ruby
options = {app_id: 'your_artemis_application_id',
           app_secret: 'your_artemis_secret_id',
           base_uri: 'https://portal.artemisag.com'}
client = ArtemisApi::Client.new('your_access_token', 'your_refresh_token', 7200, Time.zone.now, options)
```

Alternatively, instead of passing in options, you can set those values as ENV variables called `ENV['ARTEMIS_OAUTH_APP_ID']`, `ENV['ARTEMIS_OAUTH_APP_SECRET']` and `ENV['ARTEMIS_BASE_URI']`

They will be automatically detected and then you don't have to pass in any options:
```ruby
client = ArtemisApi::Client.new('your_access_token', 'your_refresh_token', 7200, Time.zone.now)
```

Once you have a client instance, you can use it to request information from Artemis.

To get user information about the Artemis User that is associated with your application ID:
```ruby
ArtemisApi::User.get_current(client)
```

To get a list of all Artemis Facilities that you have access to:
```ruby
ArtemisApi::Facility.find_all(client)
```

To get facility information about a single Artemis Facility that you have access to, by its Artemis ID:
```ruby
ArtemisApi::Facility.find(2, client)
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
