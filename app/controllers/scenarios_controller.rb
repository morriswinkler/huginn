class ScenariosController < ApplicationController
  include SortableTable
  skip_before_filter :authenticate_user!, :only => :export

  def index
    set_table_sort sorts: %w[name public], default: { name: :asc }

    @scenarios = current_user.scenarios.reorder(table_sort).page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @scenarios }
    end
  end

  def new
    @scenario = current_user.scenarios.build

    respond_to do |format|
      format.html
      format.json { render json: @scenario }
    end
  end

  def show
    @scenario = current_user.scenarios.find(params[:id])

    set_table_sort sorts: %w[name last_check_at last_event_at last_receive_at], default: { name: :asc }
    @agents = @scenario.agents.preload(:scenarios, :controllers).reorder(table_sort).page(params[:page])

    respond_to do |format|
      format.html
      format.json { render json: @scenario }
    end
  end

  def share
    @scenario = current_user.scenarios.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @scenario }
    end
  end

  def export
    @scenario = Scenario.find(params[:id])
    raise ActiveRecord::RecordNotFound unless @scenario.public? || (current_user && current_user.id == @scenario.user_id)

    @exporter = AgentsExporter.new(:name => @scenario.name,
                                   :description => @scenario.description,
                                   :guid => @scenario.guid,
                                   :tag_fg_color => @scenario.tag_fg_color,
                                   :tag_bg_color => @scenario.tag_bg_color,
                                   :source_url => @scenario.public? && export_scenario_url(@scenario),
                                   :agents => @scenario.agents)
    response.headers['Content-Disposition'] = 'attachment; filename="' + @exporter.filename + '"'
    render :json => JSON.pretty_generate(@exporter.as_json)
  end

  def edit
    @scenario = current_user.scenarios.find(params[:id])

    respond_to do |format|
      format.html
      format.json { render json: @scenario }
    end
  end

  def create
    @scenario = current_user.scenarios.build(params[:scenario])

    respond_to do |format|
      if @scenario.save
        format.html { redirect_to @scenario, notice: 'This Scenario was successfully created.' }
        format.json { render json: @scenario, status: :created, location: @scenario }
      else
        format.html { render action: "new" }
        format.json { render json: @scenario.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @scenario = current_user.scenarios.find(params[:id])

    respond_to do |format|
      if @scenario.update_attributes(params[:scenario])
        format.html { redirect_to @scenario, notice: 'This Scenario was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @scenario.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @scenario = current_user.scenarios.find(params[:id])
    @scenario.destroy

    respond_to do |format|
      format.html { redirect_to scenarios_path }
      format.json { head :no_content }
    end
  end
end
