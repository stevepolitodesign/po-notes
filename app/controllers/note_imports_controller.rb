class NoteImportsController < ApplicationController
    before_action :authenticate_user!

    def new
    end

    def create
        # TODO Check that params[:file] exists
        ImportNotesJob.perform_later(params[:file], current_user)
        redirect_to notes_path, notice: "Importing notes. Check back later."
    end
end
