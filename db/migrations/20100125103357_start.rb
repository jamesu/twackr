Sequel.migration do
  change do
    create_table(:users, :ignore_index_errors=>true) do
      Integer :id

      String   :email
      String   :salt
      String   :token
      String   :timezone,  :null => false
      Integer  :rate,      :default => 0
      TrueClass  :confirmed, :default => false
      TrueClass  :admin,     :default => false
      String   :remember_token,            :limit => 40
      DateTime :remember_token_expires_at
      Integer  :default_project_id,  :null => false, :default => 0
      Integer  :default_client_id, :null => false, :default => 0
      Integer  :default_service_id, :null => false, :default => 0

      DateTime :created_at
      DateTime :updated_at

      primary_key [:id]
      
      index [:id], :name=>:id, :unique=>true
    end

    create_table(:clients, :ignore_index_errors=>true) do
      Integer :id
      Integer :user_id
      String :name

      primary_key [:id]
      
      index [:id], :name=>:id, :unique=>true
    end

    create_table(:projects, :ignore_index_errors=>true) do
      Integer :id
      Integer :user_id
      Integer :client_id, :null => false, :default => 0

      String   :name
      String   :tag
      Integer   :last_service_id

      primary_key [:id]
      
      index [:id], :name=>:id, :unique=>true
    end

    create_table(:services, :ignore_index_errors=>true) do
      Integer :id
      Integer :user_id
      String   :name
      String   :tag
      Integer   :rate

      primary_key [:id]
      
      index [:id], :name=>:id, :unique=>true
    end

    create_table(:entries, :ignore_index_errors=>true) do
      Integer :id
      String   :content,      :null => false, :default => ''
      String   :content_html, :null => false, :default => ''
      Integer  :service_id
      Integer  :project_id
      Integer  :user_id
      DateTime :original_start,:default => nil # time which all deltas were calculated from
      DateTime :start_date,    :default => nil
      DateTime :done_date,     :default => nil
      Integer  :seconds,       :default => 0
      Integer  :seconds_limit, :default => nil

      primary_key [:id]
      
      index [:id], :name=>:id, :unique=>true
    end
  end
end