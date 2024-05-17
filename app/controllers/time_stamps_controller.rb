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

  # GET /time_stamps/1/edit
  def edit
  end

  # POST /scan_events
  # POST /scan_events.json
  def create
    user = User.find(params[:user_id]) if params[:user_id].present?
    respond_to do |format|
      begin
        user.handle_new_time_stamp!(nil) if user.present?
        format.html { redirect_to time_stamps_url(user_filter: params[:user_id], work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.creating_time_stamp') }
      rescue
        format.html { head :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /time_stamps/1
  # PATCH/PUT /time_stamps/1.json
  def update
    respond_to do |format|
      @time_stamp.value = Time.new(time_stamp_params['value(1i)'], time_stamp_params['value(2i)'], time_stamp_params['value(3i)'],  time_stamp_params['value(4i)'],  time_stamp_params['value(5i)'], @time_stamp.value.sec)
      @time_stamp.is_in = (time_stamp_params[:is_in].present? ? (time_stamp_params[:is_in] == "1") : @time_stamp.is_in)
      @time_stamp.is_out = (time_stamp_params[:is_out].present? ? (time_stamp_params[:is_out] == "1") : @time_stamp.is_out)
      @time_stamp.was_automatically_clocked_out = (time_stamp_params[:was_automatically_clocked_out].present? ? (time_stamp_params[:was_automatically_clocked_out] == "1") : @time_stamp.was_automatically_clocked_out)
      if @time_stamp.is_out && !@time_stamp.is_in
        @time_stamp.clock_out
      elsif @time_stamp.is_in && !@time_stamp.is_out
        @time_stamp.clock_in
      end
      #blup: TODO -> still update delta & monthly even when not is_in or is_out
      was_manually_edited = (@time_stamp.changed? && params[:edit_time_stamp].present? && !current_user.is_admin)
      if was_manually_edited
        @time_stamp.was_manually_edited = true
        @time_stamp.was_manually_validated = false
      else
        @time_stamp.was_manually_validated = (time_stamp_params[:was_manually_validated].present? ? (time_stamp_params[:was_manually_validated] == "1") : @time_stamp.was_manually_validated)
      end
      if @time_stamp.save
        format.html { redirect_to time_stamps_url(user_filter: @time_stamp.user.id, work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.updating_time_stamp') }
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
      if @time_stamp.destroy
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
  def export # blup: TODO
    @member_id = params[:member_filter]
    @work_month_id = params[:work_month_filter]
    @year_id = params[:year_filter] || 0
    @scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true").order(hourly_worker_time_stamp: :desc)
    @scan_events = @scan_events.where(member: {id: @member_id}) if @member_id.present?
    if @work_month_id.present?
      @scan_events = @scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_work_month_from_id(@work_month_id, @year_id), end_of_work_month_from_id(@work_month_id, @year_id))
    else
      @scan_events = @scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_year_from_id(@year_id), end_of_year_from_id(@year_id))
    end
    csv_data = CSV.generate do |csv|
      total_day_time_h = 0
      total_removed_time_h = 0
      total_delta_time_h = 0
      max_monthly_time_h = 0
      @scan_events.each_with_index do |scan_event, i|
        wd = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'][scan_event.hourly_worker_time_stamp.localtime.wday]
        datetime = scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime)
        removed_time_h = scan_event.hourly_worker_has_removed_30_min ? 0.5 : nil
        delta_time_h = scan_event.hourly_worker_out ? (scan_event.hourly_worker_delta_time.to_f/3600).round(2) : nil
        monthly_time_h = scan_event.hourly_worker_out ? (scan_event.hourly_worker_monthly_time.to_f/3600).round(2) : nil
        day_time_h = scan_event.hourly_worker_has_removed_30_min && delta_time_h.present? ? (delta_time_h+0.5) : delta_time_h
        scan_event_hash = {
          time_stamp: "#{wd}, #{datetime}",
          first_name: scan_event.member_first_name,
          last_name: scan_event.member_last_name,
          hour_in: scan_event.hourly_worker_in ? scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime_hour) : nil,
          hour_out: scan_event.hourly_worker_out ? scan_event.hourly_worker_time_stamp.localtime.to_s(:custom_datetime_hour) : nil,
          day_time_h: day_time_h,
          removed_time_h: removed_time_h,
          delta_time_h: delta_time_h,
          monthly_time_h: monthly_time_h,
        }
        csv << scan_event_hash.keys if i == 0
        csv << scan_event_hash.values
        total_day_time_h = total_day_time_h + day_time_h.to_f
        total_removed_time_h = total_removed_time_h + removed_time_h.to_f
        total_delta_time_h = total_delta_time_h + delta_time_h.to_f
        max_monthly_time_h = monthly_time_h.to_f if monthly_time_h.to_f > max_monthly_time_h
      end
      csv << ["Total", nil, nil, nil, nil, total_day_time_h, total_removed_time_h, total_delta_time_h, max_monthly_time_h]
    end
    hourly_worker_name = @member_id.present? ? "#{Member.find(@member_id).first_name}s" : "hourly_worker"
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
      :value, :is_in, :is_out, :sick_time, :paid_leave_time, :extra_time,
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
    beginning_of_selected_month = beginning_of_year_from_id(year_id) + work_month_id.to_i.months
    beginning_of_selected_month + 24.days + 6.hours - 1.second
  end

end
