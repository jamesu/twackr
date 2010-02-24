class EntriesController < ApplicationController
  before_filter :find_project_opt, :except => [:new, :create]
  before_filter :find_project, :only => [:new, :create]
  before_filter :find_entry, :except => [:index, :new, :create, :report]
  
  def index
    last_id = (params[:last_id] || '0').to_i
    @entries = (@project || @logged_user).entries.find(:all, 
      :conditions => last_id > 0 ? ['id < ?', last_id] : {}, 
      :limit => 25, 
      :order => 'start_date DESC')
    @last_entry = @entries.length > 0 ? @entries[-1].id : 0
  end
  
  def new
    @entry = @project.entries.build()
  end
  
  def create
    @entry = (@project || @logged_user.default_project).entries.build(params[:entry])
    @entry.user = @logged_user
    
    respond_to do |f|
      if @entry.save
        f.html{ redirect_to(entries_path) }
        f.js {}
      else
        f.html{ flash.now[:info] = t('response.error'); render :action => :new }
      end
    end
  end
  
  def edit
  end
  
  def update
    respond_to do |f|
      if @entry.update_attributes(params[:entry])
        f.html{ flash.now[:info] = t('response.saved'); redirect_to(entries_path) }
        f.js {}
      else
        f.html{ flash.now[:info] = t('response.error'); render :action => :edit }
      end
    end
  end
  
  def restart
    @cloned_entry = @project.entries.build()
    @cloned_entry.clone_from(@entry)
    @entry = @cloned_entry
    
    respond_to do |f|
      if @entry.save
        f.html{ flash.now[:info] = t('response.entry_cloned'); redirect_to(entries_path) }
        f.js { render :action => :create }
      else
        f.html{ flash.now[:info] = t('response.error'); render :action => :edit }
      end
    end
  end
  
  def terminate
    @entry.terminate
    
    respond_to do |f|
      if @entry.save
        f.html{ flash.now[:info] = t('response.entry_terminated'); redirect_to(entries_path) }
        f.js { render :action => :update }
      else
        f.html{ flash.now[:info] = t('response.error'); render :action => :edit }
      end
    end
  end
  
  def destroy
    @entry_id = @entry.id
    @entry.destroy
    respond_to do |f|
      f.html { redirect_to(entries_path) }
      f.js { }
    end
  end
  
  def show
  end
  
  def report
    now = (params[:date] || Time.now).to_date
    report_period = params[:period]
    report_year = now.year
    
    days_past_week  = Proc.new {|entry| (now - entry.start_date.to_date) > 7.days}
    days_past_month = Proc.new {|entry| (now - entry.start_date.to_date) > 1.month}
    days_this_year  = Proc.new {|entry| now.year != entry.year}
    
    case report_period
    when 'week'
      day_list = make_time_list(now - 1.month + 1, now) {|d| d.cweek}
      daymap = [0] + day_list
      @grouped_entries = @logged_user.entries.reject(&days_past_month).group_by do |entry|
        entry.start_date.to_date.cweek
      end
    else
      day_list = make_time_list(now - 1.week + 1, now) {|d| d.cwday}
      daymap = [", ""Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]
      @grouped_entries = @logged_user.entries.reject(&days_past_week).group_by do |entry|
        entry.start_date.to_date.cwday
      end
    end
    
    @summed_rates = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.cost}.sum]
      else
        [key, 0]
      end
    end
    
    @summed_expected_rates = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.expected_cost}.sum]  
      else
        [key, 0]
      end
    end
    
    @summed_times = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.hours}.sum]  
      else
        [key, 0]
      end
    end
    
    @summed_expected_times = day_list.map do |key|
      if @grouped_entries.has_key?(key)
        [key, @grouped_entries[key].map{|e|e.hours_limit}.sum]  
      else
        [key, 0]
      end
    end
    
    @sum_range_list = day_list.map {|d|daymap[d]}
    
    respond_to do |f|
      f.html {}
    end
  end

private

  def make_time_list(start_date, end_date, &block)
    # includes start, up to and including end
    cur_date = start_date
    list = []
    while (cur_date <= end_date)
      list << block.call(cur_date)
      cur_date += 1
    end
    list
  end
  
  def find_entry
    begin
      @entry = (@project || @logged_user).entries.find(params[:id])
    rescue
      respond_to do |f|
        f.html { flash[:error] = t('response.invalid_entry')  }
      end
    
      return false
    end
  
    true
  end
end
