class SidesController < ApplicationController
  before_action :authenticate_user!

  #before_action :set_side, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource # from cancancan

  # GET /sides
  # GET /sides.json
  def index
    @sides = Side.paginate(page: params[:page])
  end

  # GET /sides/1
  # GET /sides/1.json
  def show
  end

  # GET /sides/new
  def new
    @side = Side.new
  end

  # GET /sides/1/edit
  def edit
  end

  # POST /sides
  # POST /sides.json
  def create
    @side = Side.new(side_params)

    respond_to do |format|
      if @side.save
        format.html { redirect_to @side, notice: 'Side was successfully created.' }
        format.json { render :show, status: :created, location: @side }
      else
        format.html { render :new }
        format.json { render json: @side.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sides/1
  # PATCH/PUT /sides/1.json
  def update
    respond_to do |format|
      if @side.update(side_params)
        format.html { redirect_to @side, notice: 'Side was successfully updated.' }
        format.json { render :show, status: :ok, location: @side }
      else
        format.html { render :edit }
        format.json { render json: @side.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sides/1
  # DELETE /sides/1.json
  def destroy
    @side.destroy
    respond_to do |format|
      format.html { redirect_to sides_url, notice: 'Side was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_side
      @side = Side.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def side_params
      params.require(:side).permit(:design_id, :order, :orientation, :margin, :width, :height,
        artifacts_attributes: [:id, :side_id, :name, :order, :description, :value, :_destroy])
    end
end
