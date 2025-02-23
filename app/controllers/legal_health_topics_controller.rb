class LegalHealthTopicsController < ApplicationController
  skip_before_action :authenticate_user! #blup
  before_action :set_legal_health_topic, only: %i[ show edit update destroy ]

  # GET /legal_health_topics or /legal_health_topics.json
  def index
    @legal_health_topics = LegalHealthTopic.all
  end

  # GET /legal_health_topics/1 or /legal_health_topics/1.json
  def show
    redirect_to legal_health_topics_path
  end

  # GET /legal_health_topics/new
  def new
    @legal_health_topic = LegalHealthTopic.new
  end

  # GET /legal_health_topics/1/edit
  def edit
  end

  # POST /legal_health_topics or /legal_health_topics.json
  def create
    @legal_health_topic = LegalHealthTopic.new(legal_health_topic_params)

    respond_to do |format|
      if @legal_health_topic.save
        format.html { redirect_to legal_health_topic_url(@legal_health_topic), notice: "Legal health topic was successfully created." }
        format.json { render :show, status: :created, location: @legal_health_topic }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @legal_health_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /legal_health_topics/1 or /legal_health_topics/1.json
  def update
    respond_to do |format|
      if @legal_health_topic.update(legal_health_topic_params)
        format.html { redirect_to legal_health_topic_url(@legal_health_topic), notice: "Legal health topic was successfully updated." }
        format.json { render :show, status: :ok, location: @legal_health_topic }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @legal_health_topic.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /legal_health_topics/1 or /legal_health_topics/1.json
  def destroy
    @legal_health_topic.destroy

    respond_to do |format|
      format.html { redirect_to legal_health_topics_url, notice: "Legal health topic was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_legal_health_topic
      @legal_health_topic = LegalHealthTopic.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def legal_health_topic_params
      params.require(:legal_health_topic).permit(:name, :weighting)
    end
end
