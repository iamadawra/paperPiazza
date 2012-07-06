class QuestionGroupsCell < QuestionsCell
  def navigation_link(args)
    @user         = args[:user] || nil
    @question     = args[:question]
    @assignment   = args[:assignment]
    @index        = args[:index]
    @prefix       = args[:prefix] || "Question"
    @anchor       = args[:anchor]
    @feedback     = args[:feedback] || false
    @show_points  = args[:show_points] || false
    render
  end
  def child_index_string(child_index)
    return (child_index+1).to_s if @index.nil? or @index == ""
    return "#{@index}.#{child_index+1}"
  end
  def feedback_class
    return ""
  end
end


