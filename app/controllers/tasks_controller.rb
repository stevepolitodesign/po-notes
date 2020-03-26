class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authorize_task, only: [:show, :edit, :update, :destroy]

  def index
    @tasks = current_user.tasks
  end

  # TODO Maybe remove show action?
  def show
  end

  def new
    @task = Task.new
  end

  def edit
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      redirect_to @task, notice: "Task added"
    else
      render "new"
    end
  end

  def update
    if @task.update(task_params)
      redirect_to @task, notice: "Task updated"
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
    params.require(:task).permit(:title)
  end
end
