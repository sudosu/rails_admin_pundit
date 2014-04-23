# RailsAdminPundit

[RailsAdmin](https://github.com/sferik/rails_admin) integration with [Pundit](https://github.com/elabs/pundit) authorization system

## Installation

Add this line to your application's Gemfile:

    gem "rails_admin_pundit", :github => "sudosu/rails_admin_pundit"

And then execute:

    $ bundle

## Usage

In your `app/policies/application_policy.rb` policy:

``` ruby
class ApplicationPolicy
  ......
  def rails_admin?(action)
    case action
      when :dashboard
        user.admin?
      when :index
        user.admin?
      when :show
        user.admin?
      when :new
        user.admin?
      when :edit
        user.admin?
      when :destroy
        user.admin?
      when :export
        user.admin?
      when :history
        user.admin?
      when :show_in_app
        user.admin?
      else
        raise ::Pundit::NotDefinedError, "unable to find policy #{action} for #{record}."
    end
  end

  # Hash of initial attributes for :new, :create and :update actions. This is optional
  def attributes_for(action)
  end

end
```

And add this lines to `config/initializers/rails_admin.rb` initializer:

``` ruby
RailsAdmin.config do |config|
  ## == Pundit ==
  config.authorize_with :pundit
  ......
end
```

Now, in your model's policy you can specify a policy for rails_admin actions. For example:

``` ruby
class CityPolicy < ApplicationPolicy
  ......
  def rails_admin?(action)
    case action
      when :delete, :update, :bulk_delete
        false
      else
        super
    end
  end
end
```
  
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

include LICENSE.txt
