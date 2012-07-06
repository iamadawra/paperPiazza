class AddCoursesToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :course_id, :integer
  end
end
