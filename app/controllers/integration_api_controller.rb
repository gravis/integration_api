#
# Licensed under the Open Source GNU public license.
# Copyright (C) 2008 Robb Shecter, greenfabric.com
#
class IntegrationApiController < ActionController::Base
  before_filter :security_check, :only => [:user, :config_info]

  # For security reasons, a vague error message
  # is given when not in debug mode.
  VAGUE_ERROR = "HTTP 501 -- Server error.\n"


  # Implementation of the public JSON Integration API:

  #
  # Return user attributes, if there is a person logged in.
  #
  def user
    user = restore_session_user(params[INTEGRATION_API_SESSION_ID_PARAM], INTEGRATION_API_SESSION_USER_ID_KEY)

    respond_to do |format|
      format.json { render :json => user.to_json }
      format.text { render :text => user.to_yaml }
    end
  end

  #
  # Return the configuration info for this server.
  #
  def config_info
    # First add the cookie name to the constants.
    cookie_name = ActionController::Base.session_options[:session_key]
    data = INTEGRATION_API_CONFIG.dup
    data[:cookie_name] = cookie_name

    respond_to do |format|
      format.json { render :json => data.to_json }
      format.text { render :text => data.to_yaml }
    end
  end




  private  

  def security_check
    if    (! INTEGRATION_API_REQUIRED_PORT.nil?) && (INTEGRATION_API_REQUIRED_PORT != request.port)
      render :text => error("Bad port: #{INTEGRATION_API_REQUIRED_PORT} is required, but got #{request.port}\n")
    elsif (! INTEGRATION_API_REQUIRED_HOST.nil?) && (INTEGRATION_API_REQUIRED_HOST != request.host)
      render :text => error("Bad host: #{INTEGRATION_API_REQUIRED_HOST} is required, but got #{request.host}\n")
    end
  end

  #
  # Return an error message, taking the debug setting
  # into account for security purposes.
  #
  def error(error_message)
    if INTEGRATION_API_DEBUG
      return error_message
    else
      return VAGUE_ERROR
    end
  end
  

  #
  # Return a user from the given session id.
  # Return nil on failure.
  #
  # Adapted from http://railsauthority.com/tutorial/...
  #   restoring-rails-session-data-when-cookies-arent-available
  #
  def restore_session_user(session_id, user_id_session_key)
    # Check if we're using cookie session store instead
    if ActionController::Base.session_store == CGI::Session::CookieStore
      sess_obj = Marshal.load( Base64.decode64( session_id ) )
      user = User.find( sess_obj[:user_id] ) 
    else  
      # not using the cookie session store, it might be the old ActiveRecordStore (no more available in rails >= 2.3) :
      # TODO : test against other stores
      session_obj = CGI::Session::ActiveRecordStore::Session.find_by_session_id(session_id)
          if session_obj.nil?
            # Session not found.
            return nil
          end
        
          # Session found; user may or may not be logged in,
          user_id = session_obj.data[user_id_session_key]
      if user_id.nil?
        # No user in the session -- user not logged in.
        return nil
      end
    
      user = User.find(user_id)  
    end
    return user
  end  

end
