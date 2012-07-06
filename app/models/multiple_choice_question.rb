# == Schema Information
#
# Table name: questions
#
#  id                  :integer         not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)  default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime        not null
#  updated_at          :datetime        not null
#  course_id           :integer
#  title               :string(255)
#

class MultipleChoiceQuestion < Question
  validates_presence_of :text

  # Assumes the input is a string containing a single integer
  def preprocess_answer(answer)
    return nil if answer.nil? or answer.blank?
    return answer.to_i
  end

  # Assumes answer is an integer and self.answers is an array containing
  # integers.
  def is_correct?(answer)
    logger.debug "in mc"
    logger.debug "in mc"
    logger.debug "in mc"
    logger.debug answer == "0"
    logger.debug answer == 0
    logger.debug self.answers
    return self.answers.include? answer
  end

  def process_editor_data(data)
    self.answers  = data[:answer]
    self.choices  = data[:choices].map{ |x| Question.strip_paragraph(Question.process_text(x)) }
    return true
  end

end
