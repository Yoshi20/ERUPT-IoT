include Recaptcha::Adapters::ViewMethods
include Recaptcha::Adapters::ControllerMethods

class MembersController < ApplicationController
  require 'will_paginate/array'

  before_action :authenticate_user!, except: [:new_extern, :create_extern, :success_extern]
  before_action :set_member, only: [:show, :edit, :update, :destroy, :create_user_from_member]
  before_action { @section = 'members' }

  # GET /members
  # GET /members.json
  def index
    @members = Member.all.includes(:abo_types, :scan_events)
    # handle search parameter
    if params[:search].present?
      begin
        @members = @members.search(params[:search])
        if @members.empty?
          flash.now[:alert] = t('flash.alert.search_members')
        end
      rescue ActiveRecord::StatementInvalid
        @members = Member.all.includes(:abo_types, :scan_events).iLikeSearch(params[:search])
        if @members.empty?
          flash.now[:alert] = t('flash.alert.search_members')
        end
      end
    end
    # handle sort parameter
    if params[:sort].present?
      case params[:sort]
      when 'abo_types'
        if params[:order] == "desc"
          @members = @members.sort_by do |m|
            m.abo_types.map(&:name).join(', ')
          end.paginate(page: params[:page], per_page: Member::MAX_MEMBERS_PER_PAGE)
        else
          @members = @members.sort_by do |m|
            m.abo_types.map(&:name).join(', ')
          end.reverse.paginate(page: params[:page], per_page: Member::MAX_MEMBERS_PER_PAGE)
        end
      when 'number_of_scans'
        @members = @members.left_joins(:scan_events).group(:id).order('COUNT(scan_events.id)').paginate(page: params[:page], per_page: Member::MAX_MEMBERS_PER_PAGE)
      else
        sanitizedOrder = ActiveRecord::Base.sanitize_sql_for_order("members.?".gsub('?', params[:sort]))
        @members = @members.order(sanitizedOrder).paginate(page: params[:page], per_page: Member::MAX_MEMBERS_PER_PAGE)
      end
    else
      @members = @members.order(created_at: :desc).paginate(page: params[:page], per_page: Member::MAX_MEMBERS_PER_PAGE)
    end
    # handle the order parameter
    if params[:order] == "desc" and !@members.is_a?(Array)
      @members = @members.reverse_order
    end
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/extern/new
  def new_extern
    @member = Member.new
    render "new_extern", layout: "application_extern"
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)
    #@member.card_id = SecureRandom.uuid
    @member.magma_coins = 0
    add_abo_types_to_member(@member)
    respond_to do |format|
      if @member.save
        format.html { redirect_to current_user.present? ? member_path(@member) : members_path, notice: t('flash.notice.creating_member') }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, alert: t('flash.alert.creating_member') }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /members/extern
  def create_extern
    @member = Member.new(member_params)
    #@member.card_id = SecureRandom.uuid
    @member.magma_coins = 0
    add_abo_types_to_member(@member)
    respond_to do |format|
      if verify_recaptcha && @member.save
        format.html { redirect_to members_extern_success_path, layout: "application_extern" }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new_extern, layout: "application_extern", alert: t('flash.alert.creating_member') }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /members/:id/create_user_from_member
  def create_user_from_member
    user = @member.user
    respond_to do |format|
      if user.present?
        format.html { redirect_to users_path, alert: "Member already has an user!" }
        format.json { render :show, status: :created, location: user }
      else
        user = User.new(
          email: @member.email,
          username: @member.first_name,
          full_name: @member.name,
          mobile_number: @member.mobile_number,
          password: "123456", # must be updated by the user afterwards
          is_hourly_worker: true,
          member_id: @member.id
        )
        if user.save
          format.html { redirect_to users_path, notice: t('flash.notice.creating_member') }
          format.json { render :show, status: :created, location: @member }
        else
          format.html { render :new_extern, alert: t('flash.alert.creating_member') }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # GET /members/extern/success
  def success_extern
    render "success_extern", layout: "application_extern"
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    add_abo_types_to_member(@member)
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to members_url, notice: t('flash.notice.updating_member') }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit, alert: t('flash.alert.updating_member') }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    @member.abo_types.delete_all
    respond_to do |format|
      if @member.destroy
        format.html { redirect_to members_url, notice: t('flash.notice.deleting_member') }
        format.json { head :no_content }
      else
        format.html { render :show, alert: t('flash.alert.deleting_member') }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /members/sync_with_ggleap
  def sync_with_ggleap
    respond_to do |format|
      if Member::sync_with_ggleap_users
        format.html { redirect_to members_path, notice: t('flash.notice.sync_with_ggleap') }
      else
        format.html { redirect_to members_path, alert: t('flash.alert.sync_with_ggleap') }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :email, :birthdate,
        :mobile_number, :gender, :canton, :comment, :wants_newsletter_emails,
        :wants_event_emails, :card_id, :magma_coins, :locked, :ggleap_uuid,
        :is_hourly_worker)
    end

    def add_abo_types_to_member(member)
      all_abo_types = AboType.all
      if params[:member].present? and params[:member][:abo_types].present?
        params[:member][:abo_types].each do |at_key_value|
          at = all_abo_types.find_by(name: at_key_value[0])
          if at.present?
            if at_key_value[1] == "0"
              member.abo_types.delete(at)
            elsif at_key_value[1] == "1" and !member.abo_types.include?(at)
              atm = AboTypesMember.new
              atm.abo_type = at
              atm.member = member
              atm.expiration_date = 1.year.from_now
              member.abo_types_members << atm
            end

          end
        end
      end
    end

end
