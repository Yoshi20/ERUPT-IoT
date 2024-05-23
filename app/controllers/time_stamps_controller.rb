class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_stamp, only: [:edit, :update, :destroy]
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @user_id = current_user.is_admin? ? params[:user_filter] : current_user.id
    @work_month_id = params[:work_month_filter]
    @year_id = params[:year_filter] || 0
    @users_for_select = User.where(is_hourly_worker: true).order(:username).map{ |m| [m.username, m.id]}
    @total_time_stamps = TimeStamp.all.includes(:user)
    @total_time_stamps = @total_time_stamps.where(user: {id: @user_id}) if @user_id.present?
    if @work_month_id.present?
      @total_time_stamps = @total_time_stamps.where("value >= ? AND value <= ?", beginning_of_work_month_from_id(@work_month_id, @year_id), end_of_work_month_from_id(@work_month_id, @year_id))
    else
      @total_time_stamps = @total_time_stamps.where("value >= ? AND value <= ?", beginning_of_year_from_id(@year_id), end_of_year_from_id(@year_id))
    end
    @time_stamps = @total_time_stamps.order(value: :desc)
    @time_stamps = @time_stamps.limit(30) unless (@user_id.present? && @work_month_id.present?)
  end

  # GET /time_stamps/new
  def new
    @time_stamp = TimeStamp.new(user_id: params[:user_id])
  end

  # GET /time_stamps/1/edit
  def edit
  end

  # POST /time_stamps
  # POST /time_stamps.json
  def create
    # click on "+"-Button to clock in or out
    if params[:user_id].present?
      user = User.find(params[:user_id])
      respond_to do |format|
        begin
          user.handle_new_time_stamp!(nil) if user.present?
          format.html { redirect_to time_stamps_url(user_filter: params[:user_id], work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.creating_time_stamp') }
        rescue
          format.html { head :unprocessable_entity }
        end
      end
    # click on "submit" in /time_stamps/new
    else
      unless params["absence_dur"].present? && params["absence_type"].present?
        respond_to do |format|
          format.html { redirect_to new_time_stamp_path(user_id: time_stamp_params[:user_id]), alert: t('flash.alert.creating_time_stamp') }
        end
        return
      end
      @time_stamp = TimeStamp.new(
        value: Time.new(time_stamp_params['value(1i)'], time_stamp_params['value(2i)'], time_stamp_params['value(3i)'],  "6",  "0"),
        user_id: time_stamp_params[:user_id] || current_user.id,
        was_manually_edited: (params[:edit_time_stamp].present? && !current_user.is_admin),
      )
      @time_stamp.clock_absence(params)
      respond_to do |format|
        if @time_stamp.save
          @time_stamp.update_all_other_time_stamps_this_month
          format.html { redirect_to time_stamps_url(user_filter: @time_stamp.user_id, work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.creating_time_stamp') }
        else
          format.html { head :unprocessable_entity }
        end
      end
    end
  end

  # PATCH/PUT /time_stamps/1
  # PATCH/PUT /time_stamps/1.json
  def update
    @time_stamp.value = Time.new(time_stamp_params['value(1i)'], time_stamp_params['value(2i)'], time_stamp_params['value(3i)'],  time_stamp_params['value(4i)'],  time_stamp_params['value(5i)'], @time_stamp.value.sec)
    @time_stamp.is_in = (time_stamp_params[:is_in].present? ? (time_stamp_params[:is_in] == "1") : @time_stamp.is_in)
    @time_stamp.is_out = (time_stamp_params[:is_out].present? ? (time_stamp_params[:is_out] == "1") : @time_stamp.is_out)
    @time_stamp.was_automatically_clocked_out = (time_stamp_params[:was_automatically_clocked_out].present? ? (time_stamp_params[:was_automatically_clocked_out] == "1") : @time_stamp.was_automatically_clocked_out)
    if @time_stamp.is_out && !@time_stamp.is_in
      @time_stamp.clock_out
    elsif @time_stamp.is_in && !@time_stamp.is_out
      @time_stamp.clock_in
    else
      @time_stamp.clock_absence(params)
    end
    # handle was_manually_edited
    was_manually_edited = (@time_stamp.changed? && params[:edit_time_stamp].present? && !current_user.is_admin)
    if was_manually_edited
      @time_stamp.was_manually_edited = true
      @time_stamp.was_manually_validated = false
    else
      @time_stamp.was_manually_validated = (time_stamp_params[:was_manually_validated].present? ? (time_stamp_params[:was_manually_validated] == "1") : @time_stamp.was_manually_validated)
    end
    respond_to do |format|
      if @time_stamp.save
        @time_stamp.update_all_other_time_stamps_this_month
        format.html { redirect_to time_stamps_url(user_filter: @time_stamp.user_id, work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.updating_time_stamp') }
        format.json { render :show, status: :ok, location: @time_stamp }
      else
        format.html { render :edit, alert: t('flash.alert.updating_time_stamp') }
        format.json { render json: @time_stamp.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /time_stamps/1
  # DELETE /time_stamps/1.json
  def destroy
    respond_to do |format|
      time_stamp_id = @time_stamp.id
      temp_time_stamp = @time_stamp.dup
      if @time_stamp.destroy
        temp_time_stamp.update_all_other_time_stamps_this_month
        # also try to delete the automatic clock out delayed job
        Delayed::Job.find_by(queue: "time_stamp_#{time_stamp_id}")&.destroy
        format.html { redirect_to time_stamps_url(user_filter: params[:user_id], work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.deleting_time_stamp') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_time_stamp') }
        format.json { render json: @time_stamp.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /time_stamps/export
  require 'csv'
  def export
    @user_id = params[:user_filter]
    @work_month_id = params[:work_month_filter] # can be nil
    @year_id = params[:year_filter] || 0
    @total_time_stamps = TimeStamp.all.includes(:user)
    @total_time_stamps = @total_time_stamps.where(user: {id: @user_id}) if @user_id.present?
    beginning_of_work_month = beginning_of_work_month_from_id(@work_month_id, @year_id)
    end_of_work_month = end_of_work_month_from_id(@work_month_id, @year_id)
    csv_data = CSV.generate do |csv|
      total_day_time_h = 0
      total_removed_time_h = 0
      total_added_time_h = 0
      total_sick_time_d = 0
      total_paid_leave_time_d = 0
      total_extra_time_h = 0
      total_delta_time_h = 0
      max_monthly_time_h = 0
      is_header = true
      total_days = (end_of_work_month.to_date - beginning_of_work_month.to_date).to_i
      # loop over all days of the work month
      total_days.times do |i|
        current_value = (beginning_of_work_month + i.days)
        wd = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'][current_value.localtime.wday]
        current_time_stamps = @total_time_stamps.where("value >= ? AND value <= ?", TimeStamp::beginning_of_work_day(current_value), TimeStamp::end_of_work_day(current_value)).order(value: :asc)
        if current_time_stamps.any?
          # work day
          current_time_stamps.each do |ts|
            datetime = ts.value.localtime.to_s(:custom_datetime)
            removed_time_h = (ts.removed_break_time.to_f/3600).round(2)
            added_night_h = (ts.added_night_time.to_f/3600).round(2)
            delta_time_h = ts.has_monthly_time? ? (ts.delta_time.to_f/3600).round(2) : nil
            monthly_time_h = ts.has_monthly_time? ? (ts.monthly_time.to_f/3600).round(2) : nil
            day_time_h = ((ts.delta_time.to_i + ts.removed_break_time.to_i - ts.added_night_time.to_i).to_f/3600).round(2)
            day_sick_d = ts.is_sick ? (delta_time_h.to_f/8).round(2) : 0
            day_paid_leave_d = ts.is_paid_leave ? (delta_time_h.to_f/8).round(2) : 0
            day_extra_h = (ts.extra_time.to_f/3600).round(2)
            time_stamp_hash = {
              time_stamp: "#{wd}, #{datetime}",
              type: ts.type,
              username: ts.user.username,
              hour_in: ts.is_in ? ts.value.localtime.to_s(:custom_datetime_hour) : nil,
              hour_out: ts.is_out ? ts.value.localtime.to_s(:custom_datetime_hour) : nil,
              day_time_h: day_time_h,
              removed_time_h: removed_time_h,
              added_night_h: added_night_h,
              day_sick_d: day_sick_d,
              day_paid_leave_d: day_paid_leave_d,
              day_extra_h: day_extra_h, #blup: TODO
              delta_time_h: delta_time_h,
              monthly_time_h: monthly_time_h,
            }
            csv << time_stamp_hash.keys if is_header
            csv << time_stamp_hash.values
            is_header = false
            total_day_time_h = total_day_time_h + day_time_h.to_f
            total_removed_time_h = total_removed_time_h + removed_time_h.to_f
            total_added_time_h = total_added_time_h + added_night_h.to_f
            total_sick_time_d = total_sick_time_d + day_sick_d.to_f
            total_paid_leave_time_d = total_paid_leave_time_d + day_paid_leave_d.to_f
            total_extra_time_h = total_extra_time_h + day_extra_h.to_f
            total_delta_time_h = total_delta_time_h + delta_time_h.to_f
            max_monthly_time_h = monthly_time_h.to_f if monthly_time_h.to_f > max_monthly_time_h
          end
        else
          # rest day
          datetime = current_value.localtime.to_s(:custom_datetime)
          time_stamp_hash = {
            time_stamp: "#{wd}, #{datetime}",
            type: "DAY OFF",
            username: nil,
            hour_in: nil,
            hour_out: nil,
            day_time_h: nil,
            removed_time_h: nil,
            added_night_h: nil,
            day_sick_d: nil,
            day_paid_leave_d: nil,
            day_extra_h: nil,
            delta_time_h: nil,
            monthly_time_h: nil,
          }
          csv << time_stamp_hash.keys if is_header
          csv << time_stamp_hash.values
          is_header = false
        end
      end
      # add row with the totals
      csv << ["Total", nil, nil, nil, nil, total_day_time_h, total_removed_time_h, total_added_time_h, total_sick_time_d, total_paid_leave_time_d, total_extra_time_h, total_delta_time_h, max_monthly_time_h].map{|v| v.is_a?(Numeric) ? v.round(2) : v}
    end
    hourly_worker_name = @user_id.present? ? "#{User.find(@user_id).username}s" : "hourly_worker"
    send_data(csv_data.gsub('""', ''), type: 'text/csv', filename: "#{hourly_worker_name}_time_stamps_#{Time.now.to_i}.csv")
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_stamp
    @time_stamp = TimeStamp.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def time_stamp_params
    params.require(:time_stamp).permit(
      :value, :is_in, :is_out, :is_sick, :is_paid_leave, :extra_time,
      :delta_time, :monthly_time, :removed_break_time, :added_night_time,
      :was_automatically_clocked_out, :was_manually_edited,
      :was_manually_validated, :scan_event_id, :user_id,
    )
  end

  def beginning_of_year_from_id(year_id)
    Time.now.beginning_of_year - year_id.to_i.years
  end

  def end_of_year_from_id(year_id)
    beginning_of_year_from_id(year_id) + 1.year - 1.second
  end

  def beginning_of_work_month_from_id(work_month_id, year_id)
    beginning_of_selected_month = beginning_of_year_from_id(year_id) + work_month_id.to_i.months
    beginning_of_selected_month - 1.month + 24.days + 6.hours
  end

  def end_of_work_month_from_id(work_month_id, year_id)
    work_month_id = 11 unless work_month_id.present?
    beginning_of_selected_month = beginning_of_year_from_id(year_id) + work_month_id.to_i.months
    beginning_of_selected_month + 24.days + 6.hours - 1.second
  end

end
