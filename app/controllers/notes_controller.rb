class NotesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_note, only: [:show, :edit, :update, :destroy]
  before_action :authorize_note, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
  end

  def edit
  end
  
  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      redirect_to edit_note_path(@note), notice: 'Note added' 
    else
      render 'new'
    end
  end

  def update
    if @note.update(note_params)
      redirect_to edit_note_path(@note), notice: 'Note updated' 
    else
      render 'edit'
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: 'Note deleted'
  end

  private
    def set_note
      @note = Note.find(params[:id])
    end

    def authorize_note
      authorize @note
    end

    def note_params
      params.require(:note).permit(:title, :body, :public, :pinned, :tags_list)
    end
end
