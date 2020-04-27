class RemindersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reminder, only: [:edit, :update, :destroy]
  before_action :authorize_reminder, only: [:edit, :update, :destroy]

  def index
    @reminders = current_user.reminders
  end

  def new
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
      redirect_to reminders_path, notice: "Reminder created"
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
