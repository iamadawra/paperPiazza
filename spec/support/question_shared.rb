shared_context "initialize question page" do
  let(:current_user) { create(:user) }
  let(:course_membership) { create(:instructor_membership, user: current_user) }
  let(:course) { course_membership.course }
  before do
    log_in current_user
    visit new_course_question_path course
  end
end

shared_examples "standard question page" do |params|
  params ||= {}
  selectors = params[:selectors] || {}
  selectors.each {|selector| it { should have_selector selector } }
  #it { should have_selector('#question_form')}
  describe "should update the preview when entering data" do
    it "should update the title" do
      fill_in_question_title 'This is a title'
      page.should have_selector '#preview_field_header', :text=>'This is a title'
    end
    it "should update the description" do
      fill_in_question_description 'I am describing the question here. It has been described.'
      page.should have_selector '#preview_field_text', :text=> 'I am describing the question here. It has been described.'
    end
    # TODO fix this once we have new-style explanations
    #it "should update the explanation" do
    #  fill_in_question_explanation 'This question must be explained, so I am explaining it.'
    #  page.should have_selector '#preview_field_explanation', :text=> 'This question must be explained, so I am explaining it.'
    #end
  end
end
