class NoteImportsController < ApplicationController
  before_action :authenticate_user!

  def new
  end

  def create
    if is_valid_file?
      ImportNotesJob.perform_now(file: params[:file].path, user: current_user, limit: import_limit)
      redirect_to notes_path, notice: "Importing notes. Check back later."
    else
      redirect_to import_notes_path, notice: "Please upload a CSV."
    end
  end

  private

  def import_limit
    current_user.try(:plan).try(:notes_limit)
  end

  def is_valid_file?
    params[:file] && File.extname(params[:file]) == ".csv"
  end
end
