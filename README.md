# Overview

## About Authem

Authem is an email-based authentication library for ruby web apps.

## Compatibility

Authem requires Ruby 1.9.3 or newer

[![Build Status](https://secure.travis-ci.org/paulelliott/authem.png)](http://travis-ci.org/paulelliott/authem)
[![Code Climate](https://codeclimate.com/github/paulelliott/authem.png)](https://codeclimate.com/github/paulelliott/authem)

## Documentation

Please see the Authem website for up-to-date documentation: http://authem.org

## Upgrading to 2.0

- Run `bundle update authem` and make sure you are on the 2.0.x release.
- Remove references to the old Authem::Config object.
- Create the new sessions table with `rails g authem:session`.
- Replace `include Authem::ControllerSupport` with `authem_for :user`.
- Rename `signed_in?` to `user_signed_in?` OR `alias_method :signed_in?, :user_signed_in?` in your controller.
- Rename column `User#reset_password_token` to `User#password_reset_token` OR `alias_attribute :password_reset_token, :reset_password_token` in your `User` model.
- Replace calls to `user#reset_password_token!` with `user#password_reset_token`. Tokens are now generated automatically and the bang method is deprecated.
- Rename `sign_out` to `sign_out_user` OR `alias_method :sign_out, :sign_out_user`
- If you were passing a remember flag as the second argument to `sign_in`, you need to provide an options hash instead. For example, `sign_in(user, params[:remember])` would become `sign_in(user, remember: params[:remember])`.
- Blank email addresses will now produce the proper "can't be blank" validation message". Update your tests accordingly.
- Email addresses are no longer automatically downcased when calling `find_by_email` on your model. You will need to downcase the value manually if you wish to retain this behavior.
- Specify what to do when authem denies access to a user by adding something like this to your ApplicationController.
```
def deny_user_access
  redirect_to :sign_in
end
```
