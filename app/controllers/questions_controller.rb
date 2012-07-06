class QuestionsController < ApplicationController

  load_and_authorize_resource :course 
  load_and_authorize_resource :question, :through => :course
  skip_load_resource :question, :only => [:create, :search]

  def new
  end

  def create
    editor_data = ActiveSupport::JSON.decode(params[:question][:data])
    @question = Question.from_editor_data(editor_data, :course=>@course)
    respond_to do |format|
      if @question
        format.json { render :json => {:redirectURL => course_questions_url(@course), :id => @question.id} }
      else
        format.json { render :json => "There was a problem saving your question.", :status => :unprocessable_entity }
      end
    end
  end

  def show
    show_points = params[:show_points]
    respond_to do |format|
      format.html do
        if request.xhr?
          render text: (render_cell :questions, :show, question: @question, user: current_user, show_points: show_points)
        end
      end
      format.json { render :json => @question.json }
    end
  end

  def search
    key = params[:key] || ""
    @questions = Question.accessible_by(current_ability, :read).where('parent_id is NULL AND (lower(title) LIKE ? OR lower(text) LIKE ?)', "%#{key}%", "%#{key}%")
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def index

  end
end
