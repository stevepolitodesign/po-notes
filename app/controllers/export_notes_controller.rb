require "csv"
class ExportNotesController < ApplicationController
  def index
    if current_user
      @notes = current_user.notes
    else
      redirect_to new_user_session_path
    end
  end
end
