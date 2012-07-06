require "spec_helper"

describe UserMailer do
  describe "password_reset" do
    let(:user) { create(:user, perishable_token: "stuff") }
    let(:mail) { UserMailer.password_reset(user) }

    it "sends the password reset url" do
      mail.subject.should match("Password Reset")
      mail.to.should eq([user.email])
      mail.from.should eq(["no-reply@coursesharing.org"])
    end

    it "renders the body" do
      mail.body.encoded.should match(edit_password_reset_url(user.perishable_token))
    end
  end

end
