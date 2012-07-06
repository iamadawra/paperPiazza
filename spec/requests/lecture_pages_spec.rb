require 'spec_helper'

describe "Lecture pages:" do

  subject { page }

  describe "new" do

    let(:user)    { create(:user) }
    let(:course)  { create(:course) }

    before do
      create(:instructor_membership, user: user, course: course)
      log_in user
      visit new_course_lecture_path(course)
    end
    
    it { should have_selector("title", text: "Create a Lecture") } 
    it { should have_selector("h1", text: "Create a Lecture") }

    it { should have_button("Save Lecture") }

    describe "with invalid information" do
      it "should not create a lecture" do
        expect { click_button "Save Lecture" }.not_to change(Lecture, :count)
      end
    end

    describe "without a title" do
      let(:lecture) { build(:lecture, course: nil) }
      before do
        fill_in "Video Link",   with: lecture.video_url
        # FIXME slides 
        #fill_in "Slides Link",  with: lecture.slides_url
        fill_in_date_fields("lecture_release_date", Time.now)
      end
      it "should not create a lecture" do
        expect { click_button "Save Lecture" }.not_to change(Lecture, :count)
      end
    end

    describe "without a video link" do
      let(:lecture) { build(:lecture, course: nil) }
      before do
        fill_in "Title",        with: lecture.title
        # FIXME slides
        #fill_in "Slides Link",  with: lecture.slides_url
        fill_in_date_fields("lecture_release_date", Time.now)
      end
      it "should not create a lecture" do
        expect { click_button "Save Lecture" }.not_to change(Lecture, :count)
      end
    end

    describe "without a release date" do
      let(:lecture) { build(:lecture, course: nil) }
      before do
        fill_in "Title",        with: lecture.title
        fill_in "Video Link",   with: lecture.video_url
        # FIXME slides
        #fill_in "Slides Link",  with: lecture.slides_url
      end
      pending "should not create a lecture (need to figure out what the desired behavior here is..)" do
        expect { click_button "Save Lecture" }.not_to change(Lecture, :count)
      end
    end

    describe "with valid information" do
      let(:lecture) { build(:lecture, course: nil) }
      before do
        fill_in "Title",        with: lecture.title
        fill_in "Video Link",   with: lecture.video_url
        # FIXME slides
        #fill_in "Slides Link",  with: lecture.slides_url
        fill_in_date_fields("lecture_release_date", Time.now)
      end
      it "should create a lecture" do
        expect { click_button "Save Lecture" }.to change(Lecture, :count).by(1)
      end

      describe "after creating the lecture" do
        before { click_button "Save Lecture" }
        it "should redirect you to the show page" do
          page.should have_success_message(text: lecture.title)
          page.should have_selector("title",  text: lecture.title)
          page.should have_selector("h1",     text: lecture.title)
        end
      end

    end

  end

  describe "show" do

    let(:user)    { create(:user) }
    let(:course)  { create(:course) }
    let(:lecture) { create(:lecture, course: course) }

    before do
      create(:instructor_membership, user: user, course: course)
      log_in user
      visit course_lecture_path(course, lecture)
    end

    it { should have_selector("title",  text: lecture.title) } 
    it { should have_selector("h1",     text: lecture.title) }

    it "should have the video id in the player's container's data attribute" do
      find("#player_container")["data-video"].should eq(lecture.youtube_id)
    end

    pending "it should have the video"
    pending "it should have questions"
    pending "it should have questions"

  end

  describe "index" do

    let(:user)                 { create(:user) }
    let(:course)               { create(:course) }
    let!(:unpublished_lecture) { create(:lecture,  course: course,
                                        release_date: Time.now.tomorrow) }
    let!(:published_lecture)   { create(:lecture,  course: course, 
                                        release_date: Time.now.yesterday) }
    
    describe "for an instructor" do
      before do
        create(:instructor_membership, user: user, course: course)
        log_in user
        visit course_lectures_path(course)
      end

      it { should have_selector("title",  text: "Lectures") } 
      it { should have_content(published_lecture.title) }
      it { should have_content(unpublished_lecture.title) }

    end

    describe "for a student" do
      before do
        create(:student_membership, user: user, course: course)
        log_in user
        visit course_lectures_path(course)
      end

      it { should have_selector("title",  text: "Lectures") } 
      it { should have_content(published_lecture.title) }
      it { should_not have_content(unpublished_lecture.title) }

    end

  end

end
