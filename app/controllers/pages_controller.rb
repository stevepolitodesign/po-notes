class PagesController < ApplicationController
  layout "landing", only: [:home]
  before_action :authenticate_user!, only: [:dashboard]
  
  def home
  end

  def dashboard
  end
end
