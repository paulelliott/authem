# Authem

Authem is an authentication library for Ruby web applications.

## Compatibility

Authem is tested against Ruby 1.9.2, 1.9.3, Rubinius

[![Build Status](https://secure.travis-ci.org/paulelliott/authem.png)](http://travis-ci.org/paulelliott/authem)

## Installation

Add the following to your project's Gemfile:

    gem 'authem'

## Usage

### Model Setup

Tell authem which of your classes will be used for authentication

    Authem.configure do |config|
      config.user_class = User
    end

Once you've decided which class to use for authentication, make sure it has
access to database columns called:

* email
* salt
* crypted\_password

Then in your model

    include Authem::Model

#### Model Usage

Now that your class is all set up using Authem...

Provide your instance with the following attributes:

* email
* password
* password\_confirmation

Example:

    User.new(
      email: 'matt@example.com',
      password: '$ushi',
      password_confirmation: '$ushi'
    )

When saved, the password is hashed and stored as `crypted_password` in your
database.

You can call back to the model with `User#authenticate`, passing it email and
password, which returns self if the credentials are correct, otherwise
it returns nil.

### Controller Usage

In your application controller:

    include Authem::ControllerSupport

Which gives you access to

* `current_user`
* `require_user`
* `sign_in`
* `sign_out`
* `remember_me!`
* `establish_presence`
* `redirect_back_or_to`

Then require authentication for a whole controller or action(s) with:

    before_filter :require_user

For signing in users, try a SessionsController like the following

    class UserSessionsController < ApplicationController
      skip_before_filter :require_user, except: :destroy

      def create
        if sign_in(params[:email], params[:password])
          redirect_back_or_to(new_post_path)
        else
          render :new
        end
      end
    end

## Configuration

Currently, authem lets you configure the user class and sign in path:

    Authem.configure do |config|
      config.user_class   = Admin
      config.sign_in_path = :log_in
    end

## Contribute

Pull requests are welcome; please provide spec coverage for new code.

* `bundle install`
* `rake`

## Thanks

* mattonrails
* narwen
* mattpolito
