shared_examples "multiple choice question page" do |params|
  params ||= {}
  btn_create_question = params[:btn_create_question] || "Create Question"
  describe "with multiple choice questions" do
    it "should add one choice" do
      fill_in_question_type "Multiple choice"
      fill_in 'element_0_input_choice_text_0', :with => 'Red pill'
      page.should have_selector '#preview_field_choice_text_0', :text => 'Red pill'
    end
    it "should add a second choice" do
      fill_in_question_type "Multiple choice"
      fill_in_choice 0, 'Red pill'
      click_link 'Add Choice'
      fill_in_choice 1, 'Blue pill'
      page.should have_selector '#preview_field_choice_text_1', :text => 'Blue pill'
    end
    it "should select the second choice as the answer" do
      fill_in_question_type "Multiple choice"
      fill_in_choice 0, 'Red pill'
      click_link 'Add Choice'
      fill_in_choice 1, 'Blue pill'
      select_radio 1
      page.should have_selector('#preview_field_choice_status_1.chosen')
    end
    it "should accept a valid question" do
      fill_in_question_type "Multiple choice"
      fill_in_question_title "Neo's Choice"
      fill_in_question_description 'Which pill did Neo take?'
      fill_in_question_explanation "From the move 'The Matrix'"
      fill_in_choice 0, 'Blue pill'
      click_link 'Add Choice'
      fill_in_choice 1, 'Red pill'
      select_radio 1
      click_link_or_button btn_create_question
      page.should have_selector ".question>.text>p", :text=>'Which pill did Neo take?'
    end
    it "should not accept a question without text" do
      fill_in_question_type "Multiple choice"
      fill_in_question_description ''
      fill_in_choice 0, 'Blue pill'
      click_link 'Add Choice'
      fill_in_choice 1, 'Red pill'
      select_radio 1
      click_link_or_button btn_create_question
      page.should have_selector "#error_list>li"
    end
  end
end
