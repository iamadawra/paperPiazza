def fill_in_question_type(type, element=0)
  select type, from: "element_#{element}_select_type"
end

def fill_in_question_title(title, element=0)
  fill_in "element_#{element}_title", :with => title
end

def fill_in_question_description(description, element=0)
  fill_in "element_#{element}_description", :with => description
end

def fill_in_question_explanation(explanation, element=0)
  return
  # TODO FIXME when new-style explanations are implemented.
  #fill_in "element_#{element}_explanation", :with => explanation
end

def fill_in_choice(choice_num, str, element=0)
  fill_in "element_#{element}_input_choice_text_#{choice_num}", :with => str
end

def select_radio(choice_num, element=0)
  choose("element_#{element}_input_choice_#{choice_num}")
end

def select_checkbox(choice_num, element=0)
  check("element_#{element}_input_choice_#{choice_num}")
end
