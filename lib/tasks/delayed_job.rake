require 'httparty'

namespace :delayed_job do

  desc "Check delayed_job status"
  task status: :environment do # rake delayed_job:status
    resp = `RAILS_ENV=production /var/www/erupt-iot/current/bin/delayed_job status`
    # resp = `bin/delayed_job status`
    # resp = "" or "delayed_job: no instances running" -> when nothing is running
    # resp = "delayed_job: running [pid 79573]" -> when a job is running
    if resp.include?("running [pid")
      HTTParty.get('https://api.honeybadger.io/v1/check_in/yaI483') # check-in
    else
      resp = `RAILS_ENV=production /var/www/erupt-iot/current/bin/delayed_job start` # start new instance
      # resp = `bin/delayed_job start` # start new instance
      # resp = "delayed_job: process with pid 80542 started" -> when a job was started
      if resp.include?("started")
        HTTParty.get('https://api.honeybadger.io/v1/check_in/yaI483') # check-in
      end
    end
  end

end
