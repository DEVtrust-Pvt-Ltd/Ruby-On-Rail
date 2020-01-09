class PagesController < ApplicationController
  #skip_before_filter :verify_authenticity_token
  before_action :authenticate_user!

  def sign_in
    @user = User.new
  end


  def user_cart
    if params[:id]
      @shipping = ShippingAddress.find(params[:id])
    end
    @user = User.find(current_user.id)
    @pricesettings=Price.find('5');
  end

  def test
  end


  def user_form
    @user = User.find(current_user.id)
  end

  def user_edit_profile
    @user = User.find(current_user.id)
  end

  def print_custom_order
    if current_user.default_medication_lists.empty?
      redirect_to medication_list_path
    end
    @user = current_user
    @med_count = current_user.default_medication_lists.where.not(medication_name: nil).count
    end

  def admin_print_custom_order
    if current_user.default_medication_lists.empty?
      redirect_to medication_list_path
    end
    @user = current_user
    @med_count = current_user.default_medication_lists.where.not(medication_name: nil).count
  end

  def user_pdf
  end

  def download_pdf
    require "uri"
    require "net/http"
    @user = current_user
    @df_values = @user.zone_defibrillation_cardioversion_doses
    @medication_list = @user.default_medication_lists.includes(:weight_based_zones).order(:medication_name)
    # params = {user: @user, def_card_values: @df_values, med_list: @medication_list}
    params = {user_id: current_user.id}
    if @user.default_medication_lists.where.not(medication_name: nil).count <= 20
      puts "med < 20"
    x = Net::HTTP.post_form(URI.parse("http://13.59.158.87/pdf/?user_id=#{@user.id}"), params)
    else
      puts "med > 20"
      x = Net::HTTP.post_form(URI.parse("http://13.59.158.87/pdf/?user_id=#{@user.id}"), params)
    end      
  end
  def get_csv
    require 'csv'
    @user = current_user
    values = @user.default_medication_lists
    respond_to do |format|
      format.html
      format.csv { send_data values.as_csv }
    end
  end
end
