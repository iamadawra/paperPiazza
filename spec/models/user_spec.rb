# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)
#  password_digest        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  remember_token         :string(255)
#  perishable_token       :string(255)
#  password_reset_sent_at :datetime
#  admin                  :boolean          default(FALSE), not null
#  owner_id               :integer
#  topics_count           :integer          default(0)
#  posts_count            :integer          default(0)
#

require 'spec_helper'

describe User do

  before { @user = build(:user) }

  subject { @user }

  [:name, :email, :remember_token, :password_digest, :password, 
   :password_confirmation].each do |attr|
    it { should respond_to(attr) }
   end

  it { should respond_to(:authenticate) }

  it { should be_valid }

  describe "with a blank name" do

    before { @user.name = "" }

    it { should_not be_valid }

  end

  describe "with an invalid email" do 
    invalid_addresses =  %w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_addresses.each do |invalid_address|
      before { @user.email = invalid_address }
      it { should_not be_valid }
    end
  end

  describe "with a valid email" do 
    valid_addresses = %w[user@foo.com A_USER@f.b.org frst.lst@foo.jp a+b@baz.cn]
    valid_addresses.each do |valid_address|
      before { @user.email = valid_address }
      it { should be_valid }
    end
  end

  describe "with an email address that's already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "with a password that's too short" do
    before { @user.password = @user.password_confirmation = "a" * 6 }
    it { should be_invalid }
  end

  describe "with a blank password_confirmation" do
    before { @user.password = @user.password_confirmation = "" }
    it { should_not be_valid }
  end

  describe "when password doesn't match confirmation" do
    before { @user.password_confirmation = "mismatch" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    describe "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "when saved" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

  describe " when sending password reset " do

    before { @user.save }

    it "generates a unique perishable_token each time" do
      @user.send_password_reset
      last_token = @user.perishable_token
      @user.send_password_reset
      @user.perishable_token.should_not eq(last_token)
    end

    it "saves the time the password reset was sent" do
      @user.send_password_reset
      @user.reload.password_reset_sent_at.should be_present
    end

    it "delivers an email to the user" do
      @user.send_password_reset
      last_email.to.should include(@user.email)
    end

  end

end
