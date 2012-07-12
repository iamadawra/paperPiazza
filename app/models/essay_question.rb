# == Schema Information
#
# Table name: questions
#
#  id                  :integer          not null, primary key
#  type                :string(100)
#  text                :text
#  choices             :text
#  answers             :text
#  explanations        :text
#  parent_id           :integer
#  child_index         :integer
#  weight              :decimal(10, 4)   default(1.0)
#  json                :text
#  raw_source          :text
#  raw_source_format   :string(255)
#  javascript_includes :text
#  parameters          :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  course_id           :integer
#  title               :string(255)
#

class EssayQuestion < Question

  def process_editor_data(data)
    self.save
  end

  def grade(answer, entry)
    if self.is_correct?(answer)
      return self.weighted_points(entry.points)
    else
      return 0
    end
  end

  def is_correct?(answer)
    return true
  end
end
