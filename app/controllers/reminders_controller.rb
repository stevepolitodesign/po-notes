class RemindersController < ApplicationController
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!
  before_action :set_reminder, only: [:edit, :update, :destroy]
  before_action :authorize_reminder, only: [:edit, :update, :destroy]

  def index
    @reminders = current_user.reminders.upcoming
  end

  def new
    flash[:notice] = "#{link_to "Add your telephone number", edit_user_registration_path, class: "text-white underline hover:text-gray-200"} to receive an alert." unless current_user.telephone.present?
    @reminder = Reminder.new
  end

  def edit
  end

  def create
    @reminder = current_user.reminders.create(reminder_params)
    authorize @reminder
    if @reminder.save
      redirect_to reminders_path, notice: "Reminder added"
    else
      render "new"
    end
  end

  def update
    @reminder.update(reminder_params)
    if @reminder.save
      redirect_to reminders_path, notice: "Reminder updated"
    else
      render "edit"
    end
  end

  def destroy
    @reminder.delete
    redirect_to reminders_path, notice: "Reminder deleted"
  end

  private

  def set_reminder
    @reminder = Reminder.friendly.find(params[:id])
  end

  def authorize_reminder
    authorize @reminder
  end

  def reminder_params
    params.require(:reminder).permit(:name, :body, :time)
  end
end
