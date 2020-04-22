class BadgesController < ApplicationController
  before_action :authenticate_user!, except: :guesswho

  #before_action :set_badge, only: [:show, :edit, :update, :destroy, :camera, :print, :snapshot, :crop, :generate]
  load_and_authorize_resource except: [:lookup, :guesswho]

  include ClickSorting

  # GET /badges/recent
  def recent
    @badges = Badge.complete.paginate(page: params[:page], per_page: 18)
    render 'gallery'
  end

  def guesswho
    @badges = Badge.complete.shuffle.slice(1, 12)
    render 'guesswho'
  end

  # GET /badges
  # GET /badges.json
  def index
    # sorting code -----------------------------------------------------------------------------------------
    @columns = [
      { title: 'Emp #',      key: 'badges.employee_id' },
      { title: 'Name',       key: 'badges.last_name, badges.first_name' },
      { title: 'Title',      key: 'badges.title' },
      { title: 'Department', key: 'badges.department' },
      { title: 'Created',    key: 'badges.created_at' }
    ]
    default_sort = '-badges.created_at'
    redirect_url = badges_path
    sort = click_sort_info(@columns, default_sort, redirect_url)
#    return if performed?
    Rails.logger.debug("click_sorting = #{sort}")
    # end of sorting code, returns "sort", order your results like so:  ...reorder(sort) --------------------
    
    source = Badge.all #paginate(page: params[:page])
    pg_size = 25
    filter_list source, pg_size, sort
  end

  def filter_list source, pg_size, sort

    # get filter from cookie
    if cookies["#{controller_name}_#{action_name}_filter"].present?
      hf = JSON.parse(cookies["#{controller_name}_#{action_name}_filter"])
      @filter_user = hf['user']
      @filter_title = hf['title']
      @filter_department = hf['department']
    end

    # overlay with filter from params
    if params[:filter].present?
      @filter_title = filter_params[:title] if filter_params.include?(:title)
      @filter_department = filter_params[:department] if filter_params.include?(:department)
      @filter_user = filter_params[:user] if filter_params.include?(:user)
    end

    where_clause = ''
    where_params = {}

    # reset filter
    if params[:commit] == 'Reset'
      @filter_department = ''
      @filter_user = ''
      @filter_title = ''

      cookies.delete "#{controller_name}_#{action_name}_filter"
    else
      # save the filter to the cookie
      cookies["#{controller_name}_#{action_name}_filter"] = JSON.generate({
        department: @filter_department,
        user: @filter_user,
        title: @filter_title
      })
    end

    # apply filter
    unless @filter_department.blank?
      where_clause += " and " unless where_clause.blank?
      where_clause += "badges.department = :department" 
      where_params[:department] = @filter_department
    end
    unless @filter_title.blank?
      where_clause += " and " unless where_clause.blank?
      where_clause += "badges.title = :title" 
      where_params[:title] = @filter_title
    end
    unless @filter_user.blank?
      where_clause += " and " unless where_clause.blank?
      where_clause += "concat(badges.first_name, ' ', badges.last_name) = :filtered_user"
      where_params[:filtered_user] = @filter_user
    end

    # prepare filter choices
    @filter_departments = Badge.unscope(:order).distinct.pluck(:department).sort
    @filter_titles = Badge.unscope(:order).distinct.pluck(:title).sort
    @filter_users = Badge.unscope(:order).select(:first_name, :last_name).map{|b| b.first_name + " " + b.last_name}.sort.uniq

    @badges = source.where(where_clause, where_params).reorder(sort)

    # paginate it
    @badges = @badges.paginate(page: params[:page], per_page: pg_size)
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

  def publish
    begin
      @badge.update_thumbnail = true
      @badge.update_ad_thumbnail
      @badge.save
      render json: { status: 'Y', id: @badge.id }
    rescue => e
      render json: { status: 'N', message: e.message, id: @badge.id }
    rescue Exception => e
      render json: { status: 'N', message: e.message, id: @badge.id }
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
    require 'rest-client'

    id = @badge.id

    if params[:badge].present? and params[:badge][:picture].present?
      # do it the paperclip way
      @badge.update(snapshot_params)
    else
      # do it the raw_post way from the jpeg_camera js
      File.open("/tmp/picture_#{id}.jpg", 'wb') do |f|
        f.write(request.raw_post)
      end
      @badge.picture =  File.open "/tmp/picture_#{id}.jpg"
      @badge.save!
      File.delete("/tmp/picture_#{id}.jpg") if File.exist?("/tmp/picture_#{id}.jpg")
    end

    # response = RestClient.post "https://lambda-face-recognition.p.rapidapi.com/detect",
    #   { files: File.new(@badge.picture.path(:badge)) },
    #   { 
    #     "X-RapidAPI-Host" => "lambda-face-recognition.p.rapidapi.com", 
    #     "X-RapidAPI-Key" => "DG3G8aFfsemshG7TRzYqz5f9FFPwp1BroDejsncx7nQ6T06SW3",
    #   }

    results = nil # JSON.parse(response)
    s = "handleSnapshotUploadResponse('" + { url: @badge.picture.url(:badge), results: results }.to_json.to_s + "');"

    respond_to do |format|
      format.html { render text: @badge.picture.url(:badge) }
      format.json { render json: { url: @badge.picture.url(:badge), results: results }, status: :ok }
      format.js { render js: s, status: :ok }
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

    def snapshot_params
      params.require(:badge).permit(:picture)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def filter_params
      params.require(:filter).permit(:title, :department, :user, :commit)
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
