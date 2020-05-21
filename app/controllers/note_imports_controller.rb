class NoteImportsController < ApplicationController
    before_action :authenticate_user!

    def new
    end

    def create
        redirect_to notes_path, notice: "Importing notes. Check back later."
    end
end
