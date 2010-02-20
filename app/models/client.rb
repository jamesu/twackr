class Client < ActiveRecord::Base
  belongs_to :user
  has_many :projects, :dependent => :destroy
  has_many :entries, :through => :projects, :order => 'start_date DESC'
  
  def is_default_client?
    self.user.default_client_id == this.id
  end
  
  def total_time(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    Entry.sum(:seconds, :conditions => {:project_id => projs})
  end
  
  def total_expected_time(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    Entry.sum(:seconds_limit, :conditions => {:project_id => projs})
  end
  
  def total_rate(project=nil)
    projs = project.nil? ? self.project_ids : project.id
    self.entries.find(:all, :conditions => {:project_id => projs}).sum(&:cost)
  end
  
  def total_expected_rate(project=nil)
    self.entries.find(:all, :conditions => {:project_id => projs}).sum(&:expected_cost)
  end
  
end
