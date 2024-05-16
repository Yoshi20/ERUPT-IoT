class TimeStampsController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'time_stamps' }

  # GET /time_stamps
  # GET /time_stamps.json
  def index
    @member_id = params[:member_filter]
    @work_month_id = params[:work_month_filter]
    @year_id = params[:year_filter] || 0
    @members_for_select = Member.where(is_hourly_worker: true).order(:first_name).map{ |m| ["#{m.first_name} #{m.last_name[0]}.", m.id]}
    @total_scan_events = ScanEvent.all.includes(:member).where(member: {is_hourly_worker: true}).where("hourly_worker_in IS true OR hourly_worker_out IS true")
    @total_scan_events = @total_scan_events.where(member: {id: @member_id}) if @member_id.present?
    if @work_month_id.present?
      @total_scan_events = @total_scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_work_month_from_id(@work_month_id, @year_id), end_of_work_month_from_id(@work_month_id, @year_id))
    else
      @total_scan_events = @total_scan_events.where("hourly_worker_time_stamp >= ? AND hourly_worker_time_stamp <= ?", beginning_of_year_from_id(@year_id), end_of_year_from_id(@year_id))
    end
    @scan_events = @total_scan_events.order(hourly_worker_time_stamp: :desc)
    @scan_events = @scan_events.limit(30) unless (@member_id.present? && @work_month_id.present?)


    # blup
    @user_id = params[:user_filter]
    @work_month_id = params[:work_month_filter]
    @year_id = params[:year_filter] || 0
    @users_for_select = User.where(is_hourly_worker: true).order(:username).map{ |m| [m.username, m.id]}
    @total_time_stamps = TimeStamp.all.includes(:user).where(user: {is_hourly_worker: true}).where("is_in IS true OR is_out IS true")
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

  # PATCH/PUT /time_stamps/1
  # PATCH/PUT /time_stamps/1.json
  def update
    # blup
    # respond_to do |format|
    #   if scan_event_params["hourly_worker_time_stamp(5i)"].present?
    #     time_stamp = Time.new(scan_event_params['hourly_worker_time_stamp(1i)'], scan_event_params['hourly_worker_time_stamp(2i)'], scan_event_params['hourly_worker_time_stamp(3i)'],  scan_event_params['hourly_worker_time_stamp(4i)'],  scan_event_params['hourly_worker_time_stamp(5i)'], @scan_event.hourly_worker_time_stamp.sec)
    #     clocked_in = (scan_event_params[:hourly_worker_in].present? ? (scan_event_params[:hourly_worker_in] == "1") : @scan_event.hourly_worker_in)
    #     clocked_out = (scan_event_params[:hourly_worker_out].present? ? (scan_event_params[:hourly_worker_out] == "1") : @scan_event.hourly_worker_out)
    #     was_automatically_clocked_out = (scan_event_params[:hourly_worker_was_automatically_clocked_out].present? ? (scan_event_params[:hourly_worker_was_automatically_clocked_out] == "1") : @scan_event.hourly_worker_was_automatically_clocked_out)
    #     # has_removed_30_min = (scan_event_params[:hourly_worker_has_removed_30_min].present? ? (scan_event_params[:hourly_worker_has_removed_30_min] == "1") : @scan_event.hourly_worker_has_removed_30_min)
    #     has_removed_30_min = false
    #     if clocked_out
    #       last_scan_events = ScanEvent.where(member_id: @scan_event.member.id).where.not(id: @scan_event.id).where("hourly_worker_time_stamp <= ?", time_stamp)
    #       last_scan_event = last_scan_events.where(hourly_worker_in: true).order(:hourly_worker_time_stamp).last
    #       delta_time = time_stamp.to_i - last_scan_event&.hourly_worker_time_stamp.to_i
    #       if delta_time > TimeStamp::REMOVE_30MIN_AFTER.hours.to_i
    #         delta_time = delta_time - 30.minutes.to_i
    #         has_removed_30_min = true
    #       end
    #       scan_event_this_month = last_scan_events.where(hourly_worker_out: true).where("hourly_worker_time_stamp >= ?", beginning_of_work_month(time_stamp))
    #       monthly_time = delta_time + scan_event_this_month.sum(&:hourly_worker_delta_time)
    #       # delete the automatic clock out delayed job
    #       Delayed::Job.find_by(queue: "scan_event_#{last_scan_event.id}")&.destroy
    #       Delayed::Job.find_by(queue: "scan_event_#{@scan_event.id}")&.destroy
    #     end
    #     if (clocked_in || clocked_out) && !(clocked_in && clocked_out) && @scan_event.update(
    #       hourly_worker_time_stamp: time_stamp,
    #       hourly_worker_delta_time: delta_time,
    #       hourly_worker_monthly_time: monthly_time,
    #       hourly_worker_has_removed_30_min: has_removed_30_min,
    #       hourly_worker_in: clocked_in,
    #       hourly_worker_out: clocked_out,
    #       hourly_worker_was_automatically_clocked_out: was_automatically_clocked_out,
    #     )
    #       format.html { redirect_to time_stamps_url(member_filter: @scan_event.member.id, work_month_filter: params[:work_month_id], year_filter: params[:year_id]), notice: t('flash.notice.updating_scan_event') }
    #       format.json { render :show, status: :ok, location: @scan_event }
    #     else
    #       format.html { render :edit, alert: t('flash.alert.updating_scan_event') }
    #       format.json { render json: @scan_event.errors, status: :unprocessable_entity }
    #     end
    #   elsif @scan_event.card_id.present?
    #     member = Member.find(scan_event_params[:member_id]) if scan_event_params[:member_id].present?
    #     if member.present? && member.update(card_id: @scan_event.card_id)
    #       if @scan_event.update(member_id: scan_event_params[:member_id])
    #         # update also all scan_events with the same card_id
    #         ScanEvent.where(card_id: @scan_event.card_id).each do |se|
    #           se.update(member_id: scan_event_params[:member_id]);
    #         end
    #         format.html { redirect_to scan_events_url, notice: t('flash.notice.updating_scan_event') }
    #         format.json { render :show, status: :ok, location: @scan_event }
    #       else
    #         format.html { render :show, alert: t('flash.alert.updating_scan_event') }
    #         format.json { render json: @scan_event.errors, status: :unprocessable_entity }
    #       end
    #     else
    #       format.html { render :show, alert: t('flash.alert.updating_member') }
    #       format.json { render json: member.errors, status: :unprocessable_entity }
    #     end
    #   else
    #     format.html { render :show, alert: t('flash.alert.no_card_id') }
    #     format.json { render json: { alert: t('flash.alert.no_card_id') }, status: :unprocessable_entity }
    #   end
    # end
  end

  # DELETE /time_stamps/1
  # DELETE /time_stamps/1.json
  def destroy
    # blup
    # respond_to do |format|
    #   scan_event_id = @scan_event.id
    #   is_hourly_worker = @scan_event.hourly_worker_time_stamp.present?
    #   if @scan_event.destroy
    #     # also try to delete the automatic clock out delayed job
    #     Delayed::Job.find_by(queue: "scan_event_#{scan_event_id}")&.destroy
    #     format.html { redirect_to is_hourly_worker ? time_stamps_url(member_filter: params[:member_id], work_month_filter: params[:work_month_id], year_filter: params[:year_id]) : scan_events_url, notice: t('flash.notice.deleting_scan_event') }
    #     format.json { head :no_content }
    #   else
    #     format.html { render :show, alert: t('flash.alert.deleting_scan_event') }
    #     format.json { render json: @scan_event.errors, status: :unprocessable_entity }
    #   end
    # end
  end

  # POST /time_stamps/export
  require 'csv'
  def export
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
