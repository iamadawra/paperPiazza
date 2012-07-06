module QuestionsHelper

  def chosen_class(answer, index)
    if (answer.kind_of?(Array))
      answer.include?(index) ? "chosen" : nil
    else
      answer == index ? "chosen" : nil
    end
  end

  def child_index_string(child_index)
    render({:state => :child_index_string}, child_index)
  end

end
