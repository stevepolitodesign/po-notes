class NotesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :set_note, only: [:show, :edit, :update, :destroy, :versions, :version, :revert]
  before_action :authorize_note, only: [:show, :edit, :update, :destroy, :versions, :version, :revert]
  before_action :set_version, only: [:version, :revert]

  def index
    @q = current_user.notes.ransack(params[:q])
    @notes = @q.result.page params[:page]
  end

  def show
  end

  def new
    @note = Note.new
  end

  def edit
  end

  def create
    @note = current_user.notes.build(note_params)
    if @note.save
      redirect_to edit_note_path(@note), notice: "Note added"
    else
      render "new"
    end
  end

  def update
    if @note.update(note_params)
      redirect_to edit_note_path(@note), notice: "Note updated"
    else
      render "edit"
    end
  end

  def destroy
    @note.destroy
    redirect_to notes_path, notice: "Note deleted"
  end

  def versions
    @notes = @note.versions.includes([:item]).where(event: "update").page params[:page]
  end

  def version
  end

  def revert
    @reverted_note = @verion.reify
    @reverted_note.save!
    redirect_to edit_note_path(@reverted_note), notice: "Note reverted"
  end

  def deleted
    @destroyed_versions = PaperTrail::Version.where(item_type: "Note", event: "destroy").order(created_at: :desc).where_object(user_id: current_user.id)
    @latest_destroyed_versions = @destroyed_versions.filter { |v| v.reify.versions.last.event == "destroy" }.map(&:reify).uniq(&:id)
    @notes = @latest_destroyed_versions
  end

  def restore
    @latest_version = Note.new(id: params[:id]).versions.last
    if @latest_version.event == "destroy"
      @note = @latest_version.reify
      authorize_note
      if @note.save
        redirect_to edit_note_path(@note), notice: "Note restored"
      else
        render "deleted"
      end
    end
  end

  private

  def set_note
    @note = Note.friendly.find(params[:id])
  end

  def authorize_note
    authorize @note
  end

  def set_version
    @verion = PaperTrail::Version.find_by(item_id: @note.id, id: params[:version_id])
  end

  def note_params
    params.require(:note).permit(:title, :body, :public, :pinned, :tag_list)
  end
end
