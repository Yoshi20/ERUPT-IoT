class DevicesController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_device, only: [:show, :edit, :update, :destroy]
  before_action { @section = 'devices' }

  def index
    @devices = current_user.devices.includes(:device_type).order(:dev_eui)
    # @devices = filter_devices(@devices) if params[:filter].present?
    respond_to do |format|
      format.html { @devices_total_count = @devices.count }
      format.json { @devices.to_json }
    end
  end

  def show

  end

  def new
    @device = Device.new
    @device_types = DeviceType.all
  end

  def edit

  end

  def create
    @device = Device.new(device_params)
    @device.user = current_user
    respond_to do |format|
      if @device.save
        format.html { redirect_to devices_url, notice: t('flash.notice.creating_device') }
        format.json { render :show, status: :created, location: @device }
      else
        format.html { render :new, alert: t('flash.alert.creating_device') }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @device.update(device_params)
        format.html { redirect_to devices_url, notice: t('flash.notice.updating_device') }
        format.json { render :show, status: :ok, location: @device }
      else
        format.html { render :edit, alert: t('flash.alert.updating_device') }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @device.destroy
        format.html { redirect_to devices_url, notice: t('flash.notice.deleting_device') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_device') }
        format.json { render json: @device.errors, status: :unprocessable_entity }
      end
    end
  end

  # def send_downlink
  #   if @device.devaddr.present?
  #     if Rails.env.production?
  #       if params[:downlink_data].present?
  #         api = LoraApiHandler.new
  #         confirmed = (params[:downlink_confirmed] == 'true')
  #         api.send_manual_downlink(@device.devaddr, params[:downlink_data], confirmed, 42, 'immediately')
  #         notice = t('devices.send_downlink.notice.sent',data: params[:downlink_data])
  #       else
  #         notice = t('devices.send_downlink.notice.no_data')
  #       end
  #     else
  #       notice = t('devices.send_downlink.notice.not_on_prod')
  #     end
  #   else
  #     notice = t('devices.send_downlink.notice.no_devaddr')
  #   end
  #   redirect_to devices_url, notice: notice
  # end

  private

  def set_device
    begin
      @device = Device.find_by(id: Integer(params[:id]))
      if @device.blank? && params[:id].size == 6
        @device = Device.where('dev_eui LIKE ?', "%#{params[:id]}").first
      end
    rescue ArgumentError
      case params[:id].size
      when 16
        @device = Device.find_by(dev_eui: params[:id])
      when 6
        @device = Device.where('dev_eui LIKE ?', "%#{params[:id]}").first
      else
        raise ActiveRecord::RecordNotFound
      end
    end
    if @device.blank?
      raise ActiveRecord::RecordNotFound
    else
      @device
    end
  end

  def device_params
    params.require(:device).permit(
      :name, :dev_eui, :app_eui, :app_key, :hw_version, :fw_version,
      :device_type_id
    )
  end

  # def filter_devices(devices)
  #   devices = devices.search(params[:search]) if params[:search].present?
  #   devices = devices.where(id: params[:ids]) if params[:ids].present?
  #   devices = devices.where(device_type_id: params[:device_type_id]) if params[:device_type_id].present?
  #   devices = devices.where(lora_application_id: params[:lora_application_id]) if params[:lora_application_id].present?
  #   case params[:battery_percentage]
  #   when '6' # ext. power source
  #     devices.where('battery = 0')
  #   when '5' # unknown
  #     devices.where('battery IS NULL OR battery = 255')
  #   when '4'
  #     devices.where('battery < ? AND battery >= ?', 255, 190)
  #   when '3'
  #     devices.where('battery < ? AND battery >= ?', 190, 127)
  #   when '2'
  #     devices.where('battery < ? AND battery >= ?', 127, 64)
  #   when '1'
  #     devices.where('battery < ? AND battery >= ?', 64, 26)
  #   when '0'
  #     devices.where('battery < ? AND battery > 0', 26)
  #   else
  #     devices
  #   end
  # end

end
