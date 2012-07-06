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

class QuestionGroup < Question

  has_many :questions, :foreign_key => :parent_id, :order => :child_index, :dependent => :destroy

  def process_editor_data(data)
    self.save

    data[:element_list].each_with_index do |q_data, index|
      child_question = Question.from_editor_data(q_data)
      if child_question and child_question.update_attributes(child_index: index)
        self.questions << child_question
      else
        self.destroy
        return false
      end
    end
  end

end
