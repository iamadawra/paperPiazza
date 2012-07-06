require 'spec_helper'

describe "Question pages:" do
  subject { page }
  describe "new", :js=>true do
    include_context "initialize question page"
    it_should_behave_like "standard question page", :selectors => ["#question_form"]
  end   
end
