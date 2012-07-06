require 'spec_helper'

describe "Rubric pages:" do

  subject { page }

  describe "new" do
    let(:current_user) { create(:user) }
    let!(:course) { create(:course) }
    let!(:question) {create(:question, :course=>course)}
    before do
      log_in current_user
      visit new_course_question_rubric_item_path course, question
    end
    it {should have_selector '#rubric_form > h1', :text=> 'Add Rubric Item'}
    it "should accept valid parameters" do
      fill_in 'Weight', :with => 1.0
      fill_in 'Title', :with => 'Does the right stuff'
      fill_in 'Description', :with => 'This should be self explanatory'
      click_button 'Add Rubric Item'
      current_path.should eq course_question_rubric_items_path course, question
    end
    it "should require a numerical weight" do
      fill_in 'Weight', :with => 'NaN'
      fill_in 'Title', :with => 'Does the right stuff'
      fill_in 'Description', :with => 'This should be self explanatory'
      click_button 'Add Rubric Item'
      page.should have_error_message :text=>'There was a problem saving your rubric item'
      page.should have_field_error 'rubric_item_weight'
    end
    it "should require a title" do
      fill_in 'Weight', :with => 1.0
      click_button 'Add Rubric Item'
      page.should have_error_message :text=>'There was a problem saving your rubric item'
      page.should have_field_error 'rubric_item_title'
    end
  end

  describe "index" do
    let(:current_user) { create(:user) }
    let!(:course) { create(:course) }
    let!(:question) {create(:question, :course=>course)}
    let!(:item1) {create(:rubric_item, :question=>question)}
    let!(:item2) {create(:rubric_item, :question=>question)}
    before do
      log_in current_user
      visit course_question_rubric_items_path course, question
    end
    it { should have_selector "#rubric h1", :text => "Rubric for\n#{question.title}" }
    it { should have_content item1.title }
    it { should have_content item2.title }
    it { should have_link "Add Rubric Item" }
    it "should delete a rubric item" do
      click_link "delete_rubric_item_#{item1.id}"
      page.should_not have_content item1.title
    end
  end

  describe "edit" do
    let(:current_user) { create(:user) }
    let!(:course) { create(:course) }
    let!(:question) {create(:question, :course=>course)}
    let!(:item1) {create(:rubric_item, :question=>question)}
    let!(:item2) {create(:rubric_item, :question=>question)}
    before do
      log_in current_user
      visit edit_course_question_rubric_item_path course, question, item1
    end
    
    it {should have_selector '#rubric_form > h1', :text=> 'Edit Rubric Item'}
  end
end

