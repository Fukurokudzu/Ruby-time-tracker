class SprintsController < ApplicationController

  before_action :get_task
  before_action :get_project
  before_action :get_user

  def index
    @sprints = Sprint.where(task: sprint_params[:task_id]).order(created_at: :desc)
  end

  def create
    @sprint = Sprint.new(sprint_params)
    @sprint.start = Time.now

    respond_to do |format|
      if @sprint.save
        format.turbo_stream
      end
    end

  end

  def update
    # TODO: check sprint access
    @sprint = Sprint.find(params[:id])
    @sprint.end = Time.now
    @sprint.duration = get_duration(@sprint)
    
    respond_to do |format|
      if @sprint.save
        format.turbo_stream
      end
    end
  end

  private
  
  def get_task
    @task = Task.find(sprint_params[:task_id])
  end

  def get_project
    @project = Project.find(@task.project_id)
  end

  def get_user
    @user = current_user
  end

  # FIXME: should use this here instead of views
  def to_user_tz
    self.in_time_zone(current_user.timezone)
  end

  def get_duration(sprint)
    sprint.end.to_i - sprint.start.to_i
  end

  def sprint_params
    params.permit(:start, :end, :duration, :task_id)
  end

  # def update_stats
  #   @project.render_stats
  # end
end
