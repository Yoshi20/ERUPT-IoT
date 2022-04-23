namespace :ggleap do

  desc "Sync members with ggLeap users"
  task sync_users: :environment do # rake ggleap:sync_users
    Member::sync_with_ggleap_users
    puts 'done'
  end

end
