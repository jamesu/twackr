module ClientsHelper
  def client_select_fields(user)
    user.clients.map {|client| [client.name, client.id]}
  end
end
