class ProjectsController < ApplicationController
  before_filter :find_project, :except => [:index, :entries, :new, :create]
  
  def index
    @projects = @logged_user.projects
    respond_to do |f|
      f.html {}
    end
  end
  
  def entries
    @projects = @logged_user.projects
    last_id = (params[:last_id] || '0').to_i
    conds = if last_id > 0
      ['project_id IN (?) AND id < ?', @logged_user.project_ids, last_id]
    else
      ['project_id IN (?)', @logged_user.project_ids]
    end
    
    @entries = @logged_user.entries.find(:all, 
      :conditions => conds, 
      :limit => 25, 
      :order => 'start_date DESC')
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html {render 'entries/index'}
      f.js {render 'entries/index'}
    end
  end
  
  def new
    @project = @logged_user.projects.build
  end
  
  def create
    @project = @logged_user.projects.build(params[:project])
    
    respond_to do |f|
      if @project.save
        f.html{ redirect_to(projects_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @project.update_attributes(params[:project])
        f.html{ flash.now[:info] = t('response.saved'); redirect_to(projects_path) }
      else
        f.html{ flash.now[:info] = t('response.error'); render :edit }
      end
    end
  end
  
  def destroy
    respond_to do |f|
      if @project.is_default_project?
        f.html { flash[:error] = t('response.project_default'); redirect_to projects_path }
      else
        @project.destroy
        f.html { redirect_to projects_path }
      end
    end
  end
  
  def show
    last_id = (params[:last_id] || '0').to_i
    @entries = @project.entries.find(:all, 
      :conditions => last_id > 0 ? ['id < ?', last_id] : {}, 
      :limit => 25, 
      :order => 'start_date DESC')
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
    
    respond_to do |f|
      f.html {render 'entries/index'}
      f.js {render 'entries/index'}
    end
  end
  
  def report
    @projects = @logged_user.projects
    @project_times = @projects.map {|s| ((s.total_time / 60.0 / 60.0) * 10).round.to_f / 10 }
    @project_rates = @projects.map {|s| s.total_rate}
    @project_names = @projects.map {|s| s.name}
    
    respond_to do |f|
      f.html {}
    end
  end

private

  def find_project
    begin
      @project = @logged_user.projects.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_project')  }
      end

      return false
    end

    true
  end

end
