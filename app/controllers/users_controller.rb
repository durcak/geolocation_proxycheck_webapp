class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  inherit_resources
  responders :csv
  respond_to :csv, only: :index

  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(:page => params[:page])
    
    set_maps_point(@users)
    #set_maps_point(User.all)

    respond_to do |format|
      format.html
      @all_users = User.all if (format.html or format.xls)
      #format.csv #{ send_data User.to_csv }
      format.csv do
        self.response_body = Enumerator.new do |y|
          User.select("idecko", "ip", "state", "city", "latitude", "longitude", "proxy_type").copy_to do |line|
            y << line
          end
        end
      end
      format.xls
    end
  end

  def show_proxy
    @users = User.search_proxy("is_proxy:true").paginate(:page => params[:page])
    if @users.blank?
      User.count_proxy 
    end
    @users = User.search_proxy_type("proxy_type:#{params[:type]}").paginate(:page => params[:page])
    set_maps_point @users
    flash[:alert] = "#{@users.count} users using #{params[:type]}."
    render 'index'
  end

  def check_proxy
    @users = User.search_proxy("is_proxy:true").paginate(:page => params[:page])
    if @users.blank?
      User.count_proxy 
      @users = User.search_proxy("is_proxy:true").paginate(:page => params[:page])
    end
    set_maps_point @users
    flash[:alert] = "#{@users.count} users using Proxy."
    render 'index'
  end

  def delete_all
    User.delete_all
    `rm ./app/assets/images/viz_map.png`
    `cp ./app/assets/images/map.png ./app/assets/images/viz_map.png`
    redirect_to root_url, notice: "All users have been deleted."
  end

  def search
    @users = User.search(params[:search]).paginate(:page => params[:page])
    set_maps_point @users
    flash[:alert] = "We found #{@users.count} users."
    render 'index'
  end

  def import
    begin
      imported = User.import(params[:file])
      redirect_to root_url, notice: "#{imported} users imported."
    rescue => error
      puts error.message
      puts error.backtrace
      redirect_to root_url, notice: "Invalid CSV file format."
    end
  end

  def geolocate
    User.count_geolocation
    redirect_to root_url, notice: 'Geolocation was counted.'
  end

  def map
    # return array of arrays with number of users in every country with isocode
    @data =  [["Country", "Isocode", "Count"]] + (User.group(:isocode, :state).count).to_a.map(&:flatten)

    @data2 =  User.group('state').order('count_id desc').count('id').take(10)
    @data3 =  User.group('state').order('count_id desc').count('id').to_a 
    @data4 =  User.group('proxy_type').order('count_id desc').count('id').to_a
    @data4.shift
    flash[:alert] = 'Please import same data first.' if @data3.blank?
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def visualisation

  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_maps_point(users)
      @hash = Gmaps4rails.build_markers(users) do |user, marker|
        if user.latitude.blank? or user.latitude.blank?
          marker.lat 0
          marker.lng 0
        else
          marker.lat user.latitude
          marker.lng user.longitude
        end
        # marker.title user.idecko
        marker.infowindow "ID: #{user.idecko}, IP: #{user.ip},"
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:latitude, :longitude, :city, :idecko, :state, :isocode, :ip)
    end
end
