class QuestionSearchCell < Cell::Rails

  helper :application

  def select_list(args)
    @questions = args[:questions]
    @course = args[:course]
    render
  end
end
