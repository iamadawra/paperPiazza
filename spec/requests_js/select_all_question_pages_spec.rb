require 'spec_helper'

describe "Select All Question pages:" do
  subject { page }
  describe "new", :js=>true do
    include_context "initialize question page"
    it_should_behave_like "standard question page"
    it_should_behave_like "select all question page"
  end
end
