module ProjectsController


  module Handlers

  def find_project
    begin
      @project = Project.where(:user_id => @logged_user.id, :id => params[:id]).first
      raise Exception.new if @project.nil?
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_project')  }
      end

      halt
    end
  end

  end

  def self.registered(app)

  app.helpers ProjectsController::Handlers

  app.get '/projects' do
    load_session
    @projects = @logged_user.projects
    respond_to do |f|
      f.html { haml :'projects/index', :layout => :'layouts/default' }
    end
  end
  
  app.get '/projects/entries' do
    load_session
    @projects = @logged_user.projects
    last_id = (params[:last_id] || '0').to_i
    conds = if last_id > 0
      Sequel.&({:project_id => @logged_user.project_ids}, Sequel.lit('id < ?', last_id))
    else
      {:project_id => @logged_user.project_ids}
    end
    
    @prev_entry = last_id != 0 ? @logged_user.entries_dataset.where(:id => last_id).first : nil
    @entries = @logged_user.entries_dataset.where(conds).limit(25).order(Sequel.desc(:id)).all 
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html { haml :'entries/index', :layout => :'layouts/default' }
      f.js { erb :'entries/index.js' }
    end
  end
  
  app.get '/projects/new' do
    load_session
    @project = Project.new
    @project.user = @logged_user
    haml :'projects/new', :layout => :'layouts/default'
  end
  
  app.post '/projects' do
    load_session
    @project = @logged_user.build_project(params[:project])
    
    respond_to do |f|
      if @project.save
        f.html{ redirect(projects_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :new }
      end
    end
  end
  
  app.get '/projects/:id/edit' do
    load_session
    find_project
    haml :'projects/edit', :layout => :'layouts/default'
  end
  
  app.put '/projects/:id' do
    load_session
    find_project
    respond_to do |f|
      if @project.update_attributes(params[:project])
        f.html{ flash.now[:info] = t('response.saved'); redirect(projects_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :edit }
      end
    end
  end
  
  app.delete '/projects/:id' do
    load_session
    find_project
    respond_to do |f|
      if @project.is_default_project?
        f.html { flash[:error] = t('response.project_default'); redirect projects_path }
      else
        @project.destroy
        f.html { redirect projects_path }
      end
    end
  end
  
  app.get '/projects/:id' do
    load_session
    find_project
    last_id = (params[:last_id] || '0').to_i
    @prev_entry = last_id != 0 ? @project.entries_dataset.where(:id => last_id).first : nil
    @entries = @project.entries_dataset.
               where(last_id > 0 ? Sequel.lit('id < ?', last_id) : {}).
               limit(25).order(Sequel.desc(:id))

    @entries = @entries.all
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html { haml :'entries/index', :layout => :'layouts/default' }
    end
  end
  
  app.get '/projects/report' do
    load_session
    @projects = @logged_user.projects
    @project_times = @projects.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @project_rates = @projects.map {|s| s.total_rate}
    @project_names = @projects.map {|s| s.name}
    
    respond_to do |f|
      f.html { haml :'projects/report', :layout => :'layouts/default' }
    end
  end

end

end
