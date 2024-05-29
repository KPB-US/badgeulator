class DesignsController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource # from cancancan

  # GET /designs
  # GET /designs.json
  def index
    @designs = Design.paginate(page: params[:page])
  end

  # GET /designs/1
  # GET /designs/1.json
  def show
  end

  # GET /designs/new
  def new
    @design = Design.new
  end

  # GET /designs/1/edit
  def edit
  end

  def clone
    @design.clone
    redirect_to designs_path
  end

  def print
    print_design

    respond_to do |format|
      format.html { redirect_to @design }
    end
  end

  # POST /designs
  # POST /designs.json
  def create
    @design = Design.new(design_params)

    respond_to do |format|
      if @design.save
        format.html { redirect_to @design, notice: 'Design was successfully created.' }
        format.json { render :show, status: :created, location: @design }
      else
        format.html { render :new }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /designs/1
  # PATCH/PUT /designs/1.json
  def update
    respond_to do |format|
      if @design.update(design_params)
        format.html { redirect_to @design, notice: 'Design was successfully updated.' }
        format.json { render :show, status: :ok, location: @design }
      else
        format.html { render :edit }
        format.json { render json: @design.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /designs/1
  # DELETE /designs/1.json
  def destroy
    @design.destroy
    respond_to do |format|
      format.html { redirect_to designs_url, notice: 'Design was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def design_params
    params.require(:design).permit(:name, :sample, :default,
      sides_attributes: [:id, :order, :design_id, :orientation, :margin, :width, :height, :_destroy])
  end

  def print_design
    myBadge = Badge.find(2201)
    

    cmd = "lp -d IT-Magicard-RioPro #{ENV["PRINTER_OPTIONS"]} #{myBadge.card.path(:original)} 2>&1"
    output = `#{cmd}`
    printed_ok =$?.success?
    Rails.logger.info "#{cmd} = #{printed_ok}"

    if printed_ok
      flash[:notice] = "Badge was sent to printer.  #{output}"
    else
      flash[:error] = "Unable to send badge to printer.  #{output}"
    end
  end
end
