# Overview

## About Authem

Authem is an email-based authentication library for ruby web apps.

## Compatibility

Authem requires Ruby 2.0.0 or newer

[![Build Status](https://secure.travis-ci.org/paulelliott/authem.png)](http://travis-ci.org/paulelliott/authem)
[![Code Climate](https://codeclimate.com/github/paulelliott/authem.png)](https://codeclimate.com/github/paulelliott/authem)

## Documentation

Please see the Authem website for up-to-date documentation: http://authem.org

## Upgrading to 2.0

- Specify the latest alpha release in your Gemfile: `gem 'authem', '1.0.0.alpha.3'`
- Remove references to the old Authem::Config object.
- Create the new sessions table with `rails s authem:session`.
- Replace `include Authem::ControllerSupport` with `authem_for :user`.
- Rename `signed_in?` to `user_signed_in? OR `alias_method :signed_in?, :user_signed_in?` in your controller.
- Rename column `User#reset_password_token` to `User#password_reset_token` OR `alias_attribute :password_reset_token, :reset_password_token` in your `User` model.
- Replace calls to `user#reset_password_token!` with `user#password_reset_token`. Tokens are now generated automatically and the bang method is deprecated.
- Rename `sign_out` to `sign_out_user` OR `alias_method :sign_out, :sign_out_user`
