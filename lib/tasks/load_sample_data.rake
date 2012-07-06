namespace :db do
  desc "Deletes the database and fills it with sample data"
  task :populate => [:environment, :drop, :create, :migrate] do

    # If you add things you should use the create!/save! methods so that the
    # validations cause errors instead of returning nil.

    user = User.create!(name:     "Pacman",
                        email:    "pacman@pacman.com",
                        password: "pacmanpacman",
                        password_confirmation: "pacmanpacman")

    student = User.create!(name:     "Student",
                        email:    "student@student.com",
                        password: "student",
                        password_confirmation: "student")
    
    course =  Course.create!(name: "All About Colors", 
                            shortname: "Colors 1",
                            description: "My description")

    membership = CourseMembership.new
    membership.role = CourseMembership.instructor_role
    membership.course = course
    membership.user = user
    membership.save!

    membership = CourseMembership.new
    membership.role = CourseMembership.student_role
    membership.course = course
    membership.user = student
    membership.save!
    
    assignment = Assignment.new(
                                  title: "Assignment 1", 
                                  release_date: Time.now, 
                                  due_date: Time.now + 1.year)
    assignment.course = course
    assignment.save!

    question1 = MultipleChoiceQuestion.new(
                  child_index: 0,
                  title: "The Sky",
                  text: "What color is the sky?",
                  choices: ["Green", "Red", "Blue"],
                  explanations: { 2 => "Yes, it's blue", 
                                  0 => "It's not green because it's blue"}, 
                  answers: [2])
    question1.course = course
    question1.save!

    question2 = SelectAllQuestion.new(
                  child_index: 1,
                  title: "The Sky: Redux",
                  text: "What colors are often seen in the sky?",
                  choices: ["White", "Red", "Blue"],
                  explanations: { 2 => "Yes, it's blue", 
                                  1 => "Red sky at night",
                                  0 => "Clouds are white"}, 
                  answers: [0, 1, 2])
    question2.course = course
    question2.save!

    question3 = QuestionGroup.new(text: "Here are some color questions.")
    question3.course = course
    question3.save!

    question3.questions << question1 << question2

    assignment.add_question question3, 3

  end
end
