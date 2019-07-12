module UsersController
  #layout :user_layout

  module Handlers

    def find_user
      begin
        @user = User.with_pk!(params[:id]) 
      rescue
        respond_to do |f|
          f.html { flash[:error] = t('response.invalid_user'); redirect '/' }
        end
        
        halt
      end
    end
    
    def check_user_edit
      unless @logged_user.admin or @logged_user == @user
        respond_to do |f|
          f.html{ flash[:error] = t('response.invalid_user'); redirect '/' }
        end
        
        halt
      end
    end

  end

  def self.registered(app)

  app.helpers UsersController::Handlers

  app.get '/users' do
    load_session
    respond_to do |f|
      if @logged_user.admin
        @users = User.find(:all)
        f.html{}
      else
        f.html{redirect user_path(@logged_user)}
      end
    end

    haml :'users/index', :layout => :'layouts/default'
  end
  
  app.get '/users/new' do
    @user = User.new
    haml :'users/new', :layout => :'layouts/dialog'
  end
  
  app.post '/users' do
    @user = User.new(params[:user])
    
    respond_to do |f|
      if (@user.save rescue false)
        default_client = @user.build_client(:name => 'Self')
        default_client.save
        default_project = @user.build_project(:name => 'Default', :tag => 'self')
        default_project.client = default_client
        default_project.save
        default_service = @user.build_service(:name => 'Default', :tag => 'self')
        default_service.save
        
        @user.default_client = default_client
        @user.default_project = default_project
        @user.default_service = default_service
        
        @user.save_changes
        
        self.current_user = @user
        f.html{ flash.now[:info] = t('response.saved'); redirect(projects_path) }
      else  
        f.html{ flash.now[:error] = "Error saving!"; haml :'users/new', :layout => :'layouts/dialog' }
      end
    end
  end
  
  app.get '/users/:id/edit' do
    load_session
    find_user
    check_user_edit
    haml :'users/:id/edit', :layout => :'layouts/default'
  end
  

  app.get '/settings' do
    load_session
    @user = @logged_user
    haml :'users/edit', :layout => :'layouts/default'
  end
  
  app.put '/users/:id' do
    load_session
    find_user
    check_user_edit

    respond_to do |f|
      if @user.update_attributes(params[:user])
        f.html{ flash.now[:info] = t('response.saved'); redirect('/') }
      else
        f.html{ flash.now[:info] = t('response.error'); haml :'users/edit', :layout => :'layouts/default' }
      end
    end
  end
  
  app.delete '/users/:id' do
    load_session
    find_user
    check_user_edit

    destroyed = false
    if @logged_user == @user or @logged_user.admin
      self.current_user = nil if @logged_user == @user
      @user.destroy
      destroyed = true
    end
    
    respond_to do |f|
      f.html { redirect root_path }
      f.js { update_page {|p| p.redirect root_path } }
    end
  end
  
  app.get '/users/:id' do
    load_session
    find_user
    haml :'/users/show', :layout => :'layouts/default'
  end

  end
  
end
