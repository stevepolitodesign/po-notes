class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:edit, :update, :destroy]
  before_action :authorize_task, only: [:edit, :update, :destroy]

  def index
    @q = current_user.tasks.ransack(params[:q])
    @tasks = @q.result.page params[:page]
  end

  def edit
  end

  def new
    @task = Task.new
    @task.task_items.new
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      redirect_to edit_task_path(@task), notice: "Task added"
    else
      render "new"
    end
  end

  def update
    if @task.update(task_params)
      redirect_to edit_task_path(@task), notice: "Task updated"
    else
      render "edit"
    end
  end

  def destroy
    @task.destroy
    redirect_to tasks_path, notice: "Task deleted"
  end

  private

  def set_task
    @task = Task.friendly.find(params[:id])
  end

  def authorize_task
    authorize @task
  end

  def task_params
    params.require(:task).permit(:title, :tag_list, task_items_attributes: [:id, :title, :complete, :position, :_destroy])
  end
end
