def create_courses
  courses = []
  courses << create(:course, :name => "Intro to AI", :shortname => "CS 188")
  courses << create(:course, :name => "Intro to Security", :shortname => "CS 161")
  courses << create(:course, :name => "Intro to DBs", :shortname => "CS 186")
end

def join_courses(courses)
  courses.each do |c|
    visit courses_path
    click_button "join_course#{c.id}"
  end
end
