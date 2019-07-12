

module PathHelper

  def url_with_query(base, query=nil)
    if query.nil?
      base
    else
      URI::Generic.build(:path => base, :query => Rack::Utils.build_query(query)).to_s
    end
  end

  # path handers
  def users_path
    '/users'
  end

  def new_user_path
    '/users/new'
  end

  def edit_user_path(user)
    "/users/#{user.id}/edit"
  end

  def user_path(user)
    "/users/#{user.id}"
  end

  #

  def projects_path
    '/projects'
  end

  def new_project_path
    '/projects/new'
  end

  def edit_project_path(project)
    "/projects/#{project.id}/edit"
  end

  def project_path(project, q=nil)
    url_with_query("/projects/#{project.id}", q)
  end

  #

  def services_path
    '/services'
  end

  def new_service_path
    '/services/new'
  end

  def edit_service_path(service)
    "/services/#{service.id}/edit"
  end

  def service_path(service, q=nil)
    url_with_query("/services/#{service.id}", q)
  end

  #

  def entries_path(q=nil)
    url_with_query("/entries", q)
  end

  def project_entries_path(project, q=nil)
    url_with_query("/entries", (q||{}).merge(:project_id => project.id))
  end

  def entries_projects_path(q=nil)
    url_with_query("/projects/entries", q)
  end

  def new_entry_path
    '/entries/new'
  end

  def edit_entry_path(entry)
    "/entries/#{entry.id}/edit"
  end

  def entry_path(entry, q=nil)
    url_with_query("/entries/#{entry.id}", q)
  end

  def terminate_entry_path(entry, q=nil)
    url_with_query("/entries/#{entry.id}/terminate", q)
  end

  #

  def clients_path(q=nil)
    url_with_query("/clients", q)
  end

  def new_client_path
    '/entries/new'
  end

  def edit_client_path(client)
    "/clients/#{client.id}/edit"
  end

  def client_path(client, q=nil)
    url_with_query("/clients/#{client.id}", q)
  end

  #

  def new_session_path(q)
    url_with_query("/sessions/new", q)
  end

  def session_path
    "/sessions"
  end

  #


  def logout_path
    '/logout'
  end


end

class PathDirectory
  include PathHelper
end

