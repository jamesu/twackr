module ApplicationController

  def self.registered(app)
    app.get '/' do
      redirect entries_path
    end
  end
  
end
