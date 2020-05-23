class NoteImportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    if params[:file] && File.extname(params[:file]) == ".csv"
      limit = current_user.plan.notes_limit if current_user.try(:plan) && current_user.plan.respond_to?(:notes_limit)
      ImportNotesJob.perform_later(file: params[:file].path, user: current_user, limit: limit)
      redirect_to notes_path, notice: "Importing notes. Check back later."
    else
      redirect_to import_notes_path, notice: "Please upload a CSV."
    end
  end
end
