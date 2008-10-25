class IntegrationApiController < ApplicationController
  before_filter :security_check, :only => [:user, :cookie_name]

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
  # Return the name of the cookie containing the Rails session key.
  #
  def cookie_name
    name = ActionController::Base.cached_session_options[0][:session_key]

    respond_to do |format|
      format.json { render :json => name.to_json }
      format.text { render :text => name.to_yaml }
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

    return User.find(user_id)  
  end  

end
