# Authem

Authem is an email-based authentication library for Ruby web applications. It ONLY supports email/password authentication. It does not automatically integrate with Twitter, Facebook, or whatever oauth or SSO service you like the best. It is meant to handle user security but allow you to fully customize your user account behavior because the code is all yours.

## Compatibility

Authem is tested against Ruby 1.9.2, 1.9.3, 2.0.0, and Rubinius

[![Build Status](https://secure.travis-ci.org/paulelliott/authem.png)](http://travis-ci.org/paulelliott/authem)
[![Code Climate](https://codeclimate.com/github/paulelliott/authem.png)](https://codeclimate.com/github/paulelliott/authem)

## Installation

Add the following to your project's Gemfile:

    gem 'authem'

Or for Rails 4:

    gem 'authem', github: 'paulelliott/authem', branch: 'rails4'

## Usage

### Model Setup

Tell authem which of your classes will be used for authentication in `config/initializers/authem.rb`

    Authem.configure do |config|
      config.user_class = User
    end

Once you've decided which class to use for authentication, make sure it has
the right stuff in the database.

    create_table :users do |t|
      t.column :email, :string
      t.column :password_digest, :string
      t.column :remember_token, :string
      t.column :reset_password_token, :string
      t.column :session_token, :string
    end

Then in your model

    include Authem::User

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

When saved, the password is hashed and stored as `password_digest` in your
database.

### Controller Usage

In your application controller:

    include Authem::ControllerSupport

Which gives you access to

* `sign_in`
* `sign_out`
* `current_user`
* `require_user`
* `signed_in?`
* `redirect_back_or_to`

Then require authentication for a whole controller or action(s) with:

    before_filter :require_user, only: [:edit, :update]

Or get even crazier:

    before_filter :maybe_require_user_under_certain_circumstances

    private

    def maybe_require_user_under_certain_circumstances
      require_user if sky.blue? and rain.expected?
    end

For signing in/out users, try a SessionsController like the following

    class UserSessionsController < ApplicationController
      //works best with decent_exposure :)
      expose(:user) { User.find_by_email(params[:email]) }

      // expects params: { email: 'foo@example.com', password: 'bar' }
      def create
        if user && user.authenticate(params[:password])
          sign_in(user)
          redirect_back_or_to(:profile)
        else
          flash.now.alert = "Your email and password do not match"
          render :new
        end
      end

      def destroy
        sign_out
        redirect_to :root
      end
    end

Resetting passwords is a little more involved, but would look like this:

    class PasswordResetsController < ApplicationController
      //works best with decent_exposure :)
      expose(:user_by_email) { User.find_by_email(params[:email]) }
      expose(:user_by_token) { User.find_by_reset_password_token(params[:id]) }
      expose(:reset_password_email) { UserMailer.reset_password_email(user_by_email) }

      before_filter :verify_user, only: [:edit, :update]

      // expects params: { email: 'foo@example.com' }
      def create
        reset_password_email.deliver if user_by_email
        redirect_to [:new, :password_reset], alert: "Instructions for resetting your password have been sent to #{params[:email]}"
      end

      // expects params: { user: { password: 'bar', password_confirmation: 'bar' } }
      def update
        if user_by_token.reset_password(params[:user][:password], params[:user][:password_confirmation])
          sign_in(user_by_token)
          redirect_to :root
        else
          render :edit
        end
      end

      protected

      def verify_user
        unless user_by_token
          redirect_to [:new, :password_reset], alert: "We can't find your account with that token. You should try requesting another one."
        end
      end
    end


## Configuration

Authem lets you configure the user class:

    Authem.configure do |config|
      config.user_class   = Admin
    end

## Contribute

Pull requests are welcome; please provide spec coverage for new code.

* `bundle install`
* `rake`
