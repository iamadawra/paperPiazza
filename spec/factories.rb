FactoryGirl.define do
  factory :user do
    name                    "Pacman"
    sequence(:email)        {|n| "pacman#{n}@pacman.com"}
    password                "thepacman"
    password_confirmation   "thepacman"
    admin                   false

    factory :admin do
      admin true
    end

  end

  factory :course do
    name        "Introduction to Artificial Intelligence"
    shortname   "CS 188"
    term        "Fall"
    description "Teaches you about AI"
    year        2012
  end

  factory :course_membership do
    course
    user

    factory :student_membership do
      role CourseMembership.student_role
    end

    factory :instructor_membership do
      role CourseMembership.instructor_role
    end

    factory :ta_membership do
      role CourseMembership.ta_role
    end

  end

  factory :question do 
    course
    sequence(:child_index)        {|n| n}
    title         "Colors"
    explanations  {{0 => "Yes, it's blue.", 1 => "It's not green because it's blue"}}
    factory :question_in_group do
      question_group
    end

    factory :multiple_choice_question, :class => "MultipleChoiceQuestion" do
      text          "What color is the sky?"
      choices       ["Blue", "Green", "Red"]
      answers       [0]
    end

    factory :select_all_question, :class => "SelectAllQuestion" do
      text          "What colors are seen in the sky?"
      choices       ["Blue", "Green", "White", "Red"]
      answers       [0, 2]
    end

  end

  factory :question_group do

    factory :question_group_with_questions do

      ignore do
        question_count 5
      end

      after_create do |group, evaluator|
        FactoryGirl.create_list(:multiple_choice_question, 
                    evaluator.question_count, 
                    :question_group => group)
      end

    end
  end

  factory :question_submission do
    association :question, :factory => :select_all_question
    user
    answer [0,2]
  end

  factory :assignment do
    sequence(:title)        {|n| "Assignment #{n}"}

    release_date Time.now.tomorrow
    due_date Time.now.next_week
    total_points 10.0

    feedback false

    trait :gives_feedback do
      feedback true
    end

    trait :published do
      release_date Time.now
    end

    course

    factory :assignment_with_questions do

      ignore do
        question_types [:select_all_question, :multiple_choice_question, 
                        :question_group_with_questions]
      end

      after_create do |assignment, evaluator|
        evaluator.question_types.each_with_index do |question_type, i|
          entry = Factory.create(:assignment_entry, 
                                assignment: assignment,
                                question: Factory.create(
                                            question_type,
                                            course: assignment.course),
                                number: i)
        end
      end

      factory :published_assignment_with_questions, :traits => [:published]
    end

  end

  factory :assignment_entry do
    assignment
    question
  end

  factory :lecture do
    sequence(:title)        {|n| "CS188 Lecture#{n}"}
    video_url 'http://www.youtube.com/watch?v=T7-VjEAosSA'
    release_date Time.now.tomorrow
    course
    factory :lecture_with_slides do
      slides_url 'http://inst.eecs.berkeley.edu/~cs188/fa11/slides/FA11%20cs188%20lecture%201%20--%20introduction%20(2PP).pdf'
    end
  end

  factory :in_lecture_question do
    question FactoryGirl.build(:multiple_choice_question)
    association :lecture, :strategy => :build
    hours 0
    minutes 0
    seconds 1
  end

  factory :rubric_item do
    question
    sequence(:title) {|n| "Item #{n}"}
    description 'Do it right'
    weight 1.0
  end
end
