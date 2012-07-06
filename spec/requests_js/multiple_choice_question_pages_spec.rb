require 'spec_helper'

describe "Multiple Choice Question pages:" do
  subject { page }
  describe "new", :js=>true do
    include_context "initialize question page"
    it_should_behave_like "standard question page"
    it_should_behave_like "multiple choice question page"
  end
end
