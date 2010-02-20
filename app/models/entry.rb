class Entry < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :service
  
  before_create :check_entry
  
  def start(started_at=nil)
    self.start_date = started_at || Time.now
    self.seconds = nil
  end
  
  # e.g. @project #task 
  #      +1h (1 hour ago) 
  #      1h+ (expected to take 1 hour, from now) 
  #      1h (took one hour)
  TIMEVAL_REGEXP = /[\+\-]?(?:[0-9]+[sSHhMm])+[\+\-]?/
  TIMEVAL_UNIT_REGEXP = /[0-9]+[sSHhMm]/
  TAG_REGEXP = /[#\@][a-zA-Z0-9\-_]*/
  
  def format_entry
    found_service = nil
    found_project = nil

    gen = content.gsub(TAG_REGEXP) do |tag|
      is_project = tag[0...1] == '@' and found_project.nil?
      is_service = tag[0...1] == '#' and found_service.nil?

      # Find
      tag_project = is_project ? self.user.projects.find_by_tag(tag[1..-1]) : nil
      tag_service = is_service ? self.user.services.find_by_tag(tag[1..-1]) : nil

      # Assign
      found_service ||= tag_service
      found_project ||= tag_project

      # Emit tag
      if !tag_service.nil?
        "<span class=\"service\">#{tag}</span>"
      elsif !tag_project.nil?
        "<span class=\"project\">#{tag}</span>"
      elsif is_project and tag_project.nil?
        "<span class=\"project_ph\">#{tag}</span>"
      elsif is_service and tag_service.nil?
        "<span class=\"service_ph\">#{tag}</span>"
      else
        tag
      end
    end
    
    found_start = nil
    found_done = nil
    found_limit = nil
    
    # Calculate times from timeVal
    gen = gen.gsub(TIMEVAL_REGEXP) do |timeVal|
      # Parse...
      in_progress = timeVal[-1..-1] == '+'
      delta_inc = timeVal[0..0] == '+'
      delta_dec = timeVal[0..0] == '-'
      units = timeVal.scan(TIMEVAL_UNIT_REGEXP)
      hours, minutes, seconds = 0,0,0

      units.each do |u|
        case u[-1..-1].upcase
        when 'H'
          hours = u[0...-1].to_i
        when 'M'
          minutes = u[0...-1].to_i
        when 'S'
          seconds = u[0...-1].to_i
        end
      end

      delta_s = (hours*60*60) + (minutes*60) + seconds 

      # Determine start
      if delta_inc
        # will be spending x time on it
        found_start = Time.now
        found_done = in_progress ? nil : found_start + delta_s
      elsif delta_dec
        # spent x time on it already
        last_ended = Time.now
        found_done = in_progress ? nil : last_ended
        found_start = last_ended - delta_s
      else
        # expecting to spend x time on it [not confirmed]
        found_start = Time.now
        found_done = nil
        found_limit = delta_s
      end

      "<span class=\"time\">#{timeVal}</span>"
    end
    
    self.content_html = gen
    {:service => found_service, :project => found_project, :start_date => found_start, :done_date => found_done, :limit => found_limit}
  end
  
  def check_entry
    built = format_entry
    
    
    self.service = built[:service] if built[:service]
    self.project = built[:project] if built[:project]
    self.service ||= self.user.default_service
    self.project ||= self.user.default_project
    
    self.start_date = built[:start_date]
    self.done_date = built[:done_date]
    self.seconds_limit = built[:limit]
    
    self.seconds = current_time unless self.done_date.nil?
    self.start if self.start_date.nil?
  end
  
  def terminate
    self.done_date = Time.now
    self.seconds = self.done_date - self.start_date
  end
  
  def clone_from(other)
    self.user = other.user
    self.project = other.project
    self.service = other.service
    
    self.start_date = Time.now
    self.done_date = nil
    self.seconds = nil
    self.seconds_limit = other.seconds_limit
    self.is_billable = other.is_billable
  end
  
  def current_time
    if self.done_date.nil?
      # Use start
      Time.now - self.start_date
    else
      # Diff between start and end
      self.done_date - self.start_date
    end
  end

  def terminated?
    !self.done_date.nil?
  end
  
  def is_overdue?
    return false if seconds_limit.nil?
    
    self.current_time > self.seconds_limit
  end
  
  def hours
    (self.seconds || 0) / 60.0 / 60.0
  end
  
  def hours_limit
    (self.seconds_limit || self.seconds || 0) / 60.0 / 60.0
  end
  
  def expected_cost
    (self.service.rate || 0) * hours_limit
  end
  
  def cost
    (self.service.rate || 0) * hours
  end
end
