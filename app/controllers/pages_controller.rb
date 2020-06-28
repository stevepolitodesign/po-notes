class PagesController < ApplicationController
  layout "landing"
  before_action :authenticate_user!, only: [:dashboard]

  def home
  end

  def dashboard
  end
end
