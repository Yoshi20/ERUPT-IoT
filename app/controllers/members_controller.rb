class MembersController < ApplicationController
  before_action :authenticate_user!
  #before_action :authenticate_admin!, only: [:create, :destroy]
  before_action :set_member, only: [:show, :edit, :update, :destroy]
  before_action { @section = 'members' }

  # GET /members
  # GET /members.json
  def index
    @members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: t('flash.notice.creating_member') }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new, alert: t('flash.alert.creating_member') }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: t('flash.notice.updating_member') }
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :email, :birthdate, :mobile_number, :gender, :canton, :comment, :wants_newsletter_emails, :wants_event_emails, :card_id, :magma_coins, :expiration_date, :number_of_scans)
    end
end
