### 1.3.1 ###

* Bump bcrypt dependency for Rails 4.0.1 compatibility

### 1.3.0 ###

* Check for presence of password in authenticate
* Reconstantize user class when requested
* Add remember token to generated migrations
* Remove weird commas from generated migrations

### 1.2.0 ###

* Use `sign_in?` helper in `require_user` (Issue #13)
* Update rails dependencies to final release versions

### 1.1.1 ###

* Lock down bcrypt version per Rails' requirements
