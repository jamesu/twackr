class Service < ActiveRecord::Base
  belongs_to :user
  has_many :entries, :dependent => :destroy, :order => 'start_date DESC'
  validates_format_of :tag, :with => /[a-zA-Z0-9\-_]*/
  before_create :handle_rate
  
  attr :inherit_rate
  attr_accessible :name, :tag, :rate, :inherit_rate
  
  def after_initialize
    @inherit_rate = true
  end
  
  def handle_rate
    if @inherit_rate
      self.rate = self.user.rate
    else
      self.rate = self.user.rate
    end
  end
  
  def is_default_service?
    self.user.default_service_id == this.id
  end
  
  def total_time
    Entry.sum(:seconds, :conditions => {:service_id => self.id})
  end
  
  def total_expected_time
    Entry.sum(:seconds_limit, :conditions => {:service_id => self.id})
  end
  
  def total_rate
    (Entry.sum(:seconds, :conditions => {:service_id => self.id}) / 60.0 / 60.0) * (rate || 0)
  end
  
  def total_expected_rate
    (Entry.sum(:seconds_limit, :conditions => {:service_id => self.id}) / 60.0 / 60.0) * (rate || 0)
  end

end
