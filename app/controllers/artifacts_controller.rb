class ArtifactsController < ApplicationController
  before_action :authenticate_user!

  # before_action :set_artifact, only: [:show, :edit, :update, :destroy, :copy_props]
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
        update_design_sample(@artifact)
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
        update_design_sample(@artifact)

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
    update_design_sample(@artifact)
    respond_to do |format|
      format.html { redirect_to artifacts_url, notice: 'Artifact was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def copy_props
    prior = @artifact.prior
    unless prior.blank?
      prior.properties.each do |property|
        if !@artifact.properties.exists?(name: property.name)
          @artifact.properties.build({ name: property.name, value: property.value })
        end
      end
      @artifact.save
      update_design_sample(@artifact)
    end

    redirect_to artifacts_url
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_artifact
    @artifact = Artifact.find(params[:id])
  end

  def update_design_sample(artifact)
    artifact.side.design.render_card(layout_guides: false, update_sample: true)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def artifact_params
    params.require(:artifact).permit(:side_id, :name, :order, :description, :value, :attachment,
      properties_attributes: [:id, :artifact_id, :name, :value, :_destroy])
  end
end
