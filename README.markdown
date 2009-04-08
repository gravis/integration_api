Integration_API
====================


The Integration_API enables single sign-on between an existing Rails
application and any number of instances of other web applications.
The Wordpress plugin is completed, and collaborators are wanted for
plugins for other apps such as Beast, PunBB, or Vanilla.

The most current info about available plugin/adapters is available on
the Integration_API home page: 

[http://greenfabric.com/page/integration_api_home_page](http://greenfabric.com/page/integration_api_home_page)



The basic idea 
-------------- 

The key idea is to add a web services API into the existing Rails
application, which allows one or more 3rd party apps to get the
information they need, when they need it.  The API should be
configurable enough and general enough so that it can be added to any
Rails app without modification. The Rails app stays in control of all
sign-in and sign-out functions.

A 3rd party app, such as Vanilla, is installed in a subdirectory of
the Rails app on the same host.  If that is difficult to do, it can be
installed running on a different port.  These configurations will
allow it to access the Rails cookie.

The Rails app will need no custom work.  The third-party apps will
need a small amount of programming.  The following steps are performed
in PHP, Rails, or whatever development environment in which the
3rd-party app runs:

* Customize the sign-in and sign-out links to point to those in your
  Rails app.

* Customize the function that checks if a user is signed in to do the
  following:

  1. Get the Rails cookie name via the API.

  2. Check for the existence of the cookie in the browser.  Not there
  => not logged in.  If there, continue...

  3. Get the cookie data and send it to the API, which returns
  the user info.  Empty data => not logged in.  If there's
  user data, continue...

  4. Create a new [Vanilla/Wordpress/etc.] user record if none exists
  yet.

  5. Allow the [Vanilla/Wordpress/etc.] sign-in function to succeed,
  marking the user as signed in.

The hope of this project is that this process is fairly easy to code
up in mature, well-refactored 3rd-party apps.  For example, the LDAP
plugin for Wordpress would make a great starting point for an
Integration_API Wordpress plugin.

Installation
------------

Like any other rails plugin :

    ./script/plugin install git@github.com:gravis/integration_api.git
    
or if you want to use git submodules :

    git submodule add git@github.com:gravis/integration_api.git vendor/plugins/integration_api
    git submodule init
    git submodule update

Assumptions
-----------

In order to use this, you should have a working Rails app that
completely manages its authentication and users.  It should keep track
of whether a user is signed in by placing the id of a User instance
into the session.


Future plans
------------

* Make the library more flexible by supporting other user class names,
  etc.

* Write Wordpress/PunBB/Vanilla, etc. adapters that connect to this
  API.


Required constants / configuration settings
-------------------------------------------

Add these statements to your `config/environments/development.rb` and
`config/environments/production.rb`.  You'll mostly likely need to
change the `USER_ID_KEY` to the key that you use to store your user
id in the session.  For development, set the ...DEBUG variable to
true.

    # Constants for the Integration API
    INTEGRATION_API_DEBUG               = false
    INTEGRATION_API_SESSION_USER_ID_KEY = :userid
    INTEGRATION_API_SESSION_ID_PARAM    = :id
    INTEGRATION_API_CONFIG = {
      :login_url  => 'http://devbox:3000/page/sign_in',
      :logout_url => 'http://devbox:3000/consumer/logout'
    }

    # For security:
    INTEGRATION_API_REQUIRED_PORT       = 3000        # Set to nil to disable
    INTEGRATION_API_REQUIRED_HOST       = "localhost" # Set to nil to disable       


Testing the JSON API
--------------------

After copying the controller file to your app/controllers directory
and tailoring the constants, you can test the API like this:


* Getting the cookie name used by your app:

$
    curl http://localhost:3000/integration_api/config_info
    {"login_url":"http:\/\/devbox:3000\/page\/sign_in","logout_url":"http:\/\/devbox:3000\/consumer\/logout","cookie_name":"_gf_session"}  

* Getting the user info for a signed-in user, based on the session id
stored in a rails cookie. (This is what my system shows -- I use
OpenID for authentication.  You'll see different attributes,
obviously)

$
    curl http://localhost:3000/integration_api/user/390f55cfd1ad5a911833a7683d2c3793
    {"user": {"name":"Robb Shecter","updated_at":"2008-09-02T11:57:51-07:00","nickname":"Robb","id":2,"pref_announce_list":false,"homepage":null,"openid":"http:\/\/greenfabric.com\/robb\/","email":"robb.shecter@gmail.com","created_at":"2008-06-29T01:23:01-07:00"}}


* Attempting to use the API from an unauthorized host (Debug mode enabled):

$ 
    curl http://devbox:3000/integration_api/config_info
    Bad host: localhost is required, but got devbox


* Attempting to use the API from an unauthorized host (Debug mode disabled):

$
    curl http://devbox:3000/integration_api/config_info
    HTTP 501 -- Server error.

--      

Robb Shecter
robb@greenfabric.com
http://greenfabric.com/robb

This document, and the entire Integration_API project has been
released under the GNU public license.

Copyright (C) 2008, Robb Shecter, greenfabric.com