namespace :db do
  desc "Run migrations"
  task :migrate, [:version] do |t, args|
    db_path = ENV.fetch('DATABASE_URL') rescue 'sqlite://db/development.sqlite3'
    `sequel -m db/migrations #{db_path}`
  end
end