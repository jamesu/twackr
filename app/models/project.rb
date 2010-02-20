class Project < ActiveRecord::Base
  belongs_to :user
  belongs_to :client
  belongs_to :last_service, :class_name => 'LastService', :foreign_key => 'last_service_id'
  has_many :entries, :dependent => :destroy, :order => 'start_date DESC'
  
  validates_format_of :tag, :with => /[a-zA-Z0-9\-_]*/
  attr_accessible :name, :tag, :client_id
  
  def is_default_project?
    self.user.default_project_id == this.id
  end
  
  def total_time
    Entry.sum(:seconds, :conditions => {:project_id => self.id})
  end
  
  def total_expected_time
    Entry.sum(:seconds_limit, :conditions => {:project_id => self.id})
  end
  
  def total_rate
    self.entries.find(:all).sum(&:cost)
  end
  
  def total_expected_rate
    self.entries.find(:all).sum(&:expected_cost)
  end
end
