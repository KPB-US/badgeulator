class BadgesController < ApplicationController
  #before_action :set_badge, only: [:show, :edit, :update, :destroy, :camera, :print, :snapshot, :crop, :generate]
  load_and_authorize_resource except: :lookup

  # GET /badges
  # GET /badges.json
  def index
    @badges = Badge.paginate(page: params[:page])
  end

  # GET /badges/1
  # GET /badges/1.json
  def show
  end

  # GET /badges/new
  def new
    @badge = Badge.new
  end

  # GET /badges/1/edit
  def edit
  end

  # POST /badges
  # POST /badges.json
  def create
    @badge = Badge.new(badge_params)

    respond_to do |format|
      if @badge.save
        format.html { redirect_to camera_badge_url(@badge) }
        format.json { render :show, status: :created, location: @badge }
      else
        format.html { render :new }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /badges/:id/camera
  # shows camera, allows taking of snapshot
  def camera
  end

  def generate
    begin
      Design.selected.render_card(@badge)
      flash[:notice] = "Card has been generated and is ready to print."
    rescue Exception => e
      flash[:error] = "Unable to generate card - #{e.message}"
    end
    redirect_to @badge
  end

  def print
    print_badge

    respond_to do |format|
      format.html { redirect_to @badge }
    end
  end

  # PATCH/PUT /badges/1
  # PATCH/PUT /badges/1.json
  def update
    respond_to do |format|
      if @badge.update(badge_params)
        format.html { redirect_to @badge, notice: 'Badge was successfully updated.' }
        format.json { render :show, status: :ok, location: @badge }
      else
        format.html { render :edit }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /badges/1
  # DELETE /badges/1.json
  def destroy
    @badge.destroy
    respond_to do |format|
      format.html { redirect_to badges_url, notice: 'Badge was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  # GET /badges/1/crop
  def crop
    ratio = @badge.picture_geometry(:original).width / @badge.picture_geometry(:badge).width
    @badge.crop_x = params[:x].to_i * ratio
    @badge.crop_y = params[:y].to_i * ratio
    @badge.crop_w = params[:w].to_i * ratio
    @badge.crop_h = params[:h].to_i * ratio

    @badge.picture.reprocess! :badge
    @badge.picture.reprocess! :thumb

    begin
      @badge.update_ad_thumbnail
    rescue => e
      flash[:error] ||= []
      flash[:error] << e.message
    rescue Exception => e
      flash[:error] ||= []
      flash[:error] << e.message
    end

    begin
      if Design.selected.blank?
        flash[:error] ||= []
        flash[:error] << "No default design has been set."
      else
        Design.selected.render_card(@badge)
      end
    rescue Exception => e
      flash[:error] ||= []
      flash[:error] << "Unable to print card - #{e.message}"
    end

    if ENV["AUTO_PRINT"].blank? || ENV["AUTO_PRINT"] == "true"
      print_badge
    end

    respond_to do |format|
      # crop is posted via ajax so you cannot just redirect have to tell the browser to
      if ENV["AUTO_PRINT"].blank? || ENV["AUTO_PRINT"] == "true"
        format.html { render text: badges_url }
        format.json { render json: { url: badges_url } }
      else
        format.html { render text: badge_url(@badge) }
        format.json { render json: { url: badge_path(@badge) } }
      end
    end
  end

  # POST /snapshot
  def snapshot
    id = @badge.id
    File.open("/tmp/picture_#{id}.jpg", 'wb') do |f|
      f.write(request.raw_post)
    end
    @badge.picture =  File.open "/tmp/picture_#{id}.jpg"
    @badge.save!
    File.delete("/tmp/picture_#{id}.jpg") if File.exist?("/tmp/picture_#{id}.jpg")

    respond_to do |format|
      format.html { render text: @badge.picture.url(:badge) }
      format.json { render json: { url: @badge.picture.url(:badge), base64: Base64.encode64(request.raw_post) }, status: :ok }
    end
  end

  def lookup
    # find, don't find, or error
    # use ldap or not
    errors = []
    begin
      info = Badge.lookup_employee("employeeId", params[:id])
    rescue => e
      errors << "#{e.class} #{e.message}"
    end

    respond_to do |format|
      if errors.blank?
        format.html { render :lookup, layout: false, locals: { info: info } }
        format.json { render json: info, status: :ok }
      else
        format.html { render text: "<div class='alert alert-danger'>#{errors.join(', ')}</div>" }
        format.json { render json: errors, status: :not_found }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_badge
      @badge = Badge.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def badge_params
      params.require(:badge).permit(:employee_id, :first_name, :last_name, :title, :department, :dn, :update_thumbnail)
    end

    def print_badge
      if ENV["PRINTER"].blank?
        flash[:error] = "No printer defined in PRINTER environment variable."
      elsif @badge.card.blank?
        # there is no card so try to generate one
        begin
          Design.selected.render_card(@badge)
        rescue Exception => e
          flash[:error] = "Unable to generate card - #{e.message}"
        end
      end

      if flash[:error].blank?
        cmd = "lp -d #{ENV["PRINTER"]} #{ENV["PRINTER_OPTIONS"]} #{@badge.card.path(:original)} 2>&1"
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
end
