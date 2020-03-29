class TaskItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task
  before_action :set_task_item, only: [:update, :destroy]
  before_action :authorize_task

  def create
    @task_item = @task.task_items.create(task_item_params)
    redirect_to @task
  end

  def update
    @task_item.update(task_item_params)
    redirect_to @task
  end

  def destroy
    @task_item.destroy
    redirect_to @task
  end

  private

  def set_task
    @task = Task.friendly.find(params[:task_id])
  end

  def set_task_item
    @task_item = TaskItem.find(params[:id])
  end

  def authorize_task
    authorize @task
  end

  def task_item_params
    params.require(:task_item).permit(:title, :complete)
  end
end
