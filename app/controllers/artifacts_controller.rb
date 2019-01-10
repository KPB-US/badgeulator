class ArtifactsController < ApplicationController
  before_action :authenticate_user!

  #before_action :set_artifact, only: [:show, :edit, :update, :destroy, :copy_props]
  load_and_authorize_resource # from cancancan

  # GET /artifacts
  # GET /artifacts.json
  def index
    @artifacts = Artifact.paginate(page: params[:page])
  end

  # GET /artifacts/1
  # GET /artifacts/1.json
  def show
  end

  # GET /artifacts/new
  def new
    @artifact = Artifact.new
  end

  # GET /artifacts/1/edit
  def edit
  end

  # POST /artifacts
  # POST /artifacts.json
  def create
    @artifact = Artifact.new(artifact_params)

    respond_to do |format|
      if @artifact.save
        format.html { redirect_to @artifact, notice: 'Artifact was successfully created.' }
        format.json { render :show, status: :created, location: @artifact }
      else
        format.html { render :new }
        format.json { render json: @artifact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /artifacts/1
  # PATCH/PUT /artifacts/1.json
  def update
    respond_to do |format|
      if @artifact.update(artifact_params)
        # to assist in designing cards, update the sample when an artifact is updated
        # TODO! check performance
        @artifact.side.design.render_card nil, false, true

        format.html { redirect_to @artifact.side, notice: 'Artifact was successfully updated.' }
        format.json { render :show, status: :ok, location: @artifact }
      else
        format.html { render :edit }
        format.json { render json: @artifact.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /artifacts/1
  # DELETE /artifacts/1.json
  def destroy
    @artifact.destroy
    respond_to do |format|
      format.html { redirect_to artifacts_url, notice: 'Artifact was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def copy_props
    prior = Artifact.where('side_id = :side and "order" < :order', side: @artifact.side_id, order: @artifact.order).last
    unless prior.blank?
      prior.properties.each do |property|
        @artifact.properties.build({name: property.name, value: property.value}) unless @artifact.properties.exists?(name: property.name)
      end
      @artifact.save
    end

    redirect_to artifacts_url
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_artifact
      @artifact = Artifact.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def artifact_params
      params.require(:artifact).permit(:side_id, :name, :order, :description, :value, :attachment,
        properties_attributes: [:id, :artifact_id, :name, :value, :_destroy])
    end
end
