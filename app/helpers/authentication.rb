
module AuthenticatedSystem
    #
    # Login
    #

    def logged_in?
      !current_user.nil?
    end

    def current_user
      @logged_user ||= (login_from_session) unless @logged_user == false
    end

    def current_user=(new_user)
      session[:user_id] = new_user ? new_user.id : nil
      @logged_user = new_user || false
    end

    def login_required
      logged_in? || access_denied
    end

    def access_denied
      respond_to do |format|
        format.html do
          store_location if request.request_method == 'GET'
          if @token_login.nil?
            redirect '/login'
          else
            redirect new_session_path(:token => params[:token])
          end
        end

        format.json do
          json {}
        end
      end
    end

    def store_location
      session[:return_to] = request.url
    end

    def redirect_back_or_default(default)
      redirect(session[:return_to] || default)
      session[:return_to] = nil
      halt
    end

    def login_from_session
      self.current_user = User.where(:id =>session[:user_id]).first if session[:user_id]
    end

    #
    # Logout
    #

    def logout_keeping_session!
      # Kill server-side auth cookie
      @logged_user.forget_me if @logged_user.is_a? User
      @logged_user = false     # not logged in, and don't do it for me
      session[:user_id] = nil   # keeps the session but kill our variable
      # explicitly kill any other session variables you set
    end

    def logout_killing_session!
      logout_keeping_session!
      session.clear
    end

end
