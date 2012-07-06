def full_title(page_title)

  base_title = "coursesharing"

  if page_title.empty?
    base_title
  else
    "#{base_title} | #{page_title}"
  end

end

def log_in(user)
  visit login_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Log In"
  # Sign in when not using Capybara as well.
  cookies[:remember_token] = user.remember_token
end

def fill_in_date_fields(base, date)
  fill_in "#{base}_date", with: date.to_s(:form_date)
  fill_in "#{base}_time", with: date.to_s(:form_time)
end

RSpec::Matchers.define :have_error_message do |opts|
  match do |page|
    page.should have_selector('div.alert.alert-error', opts)
  end
end

RSpec::Matchers.define :have_success_message do |opts|
  match do |page|
    page.should have_selector('div.alert.alert-success', opts)
  end
end

RSpec::Matchers.define :have_info_message do |opts|
  match do |page|
    page.should have_selector('div.alert.alert-info', opts)
  end
end

RSpec::Matchers.define :have_notice_message do |opts|
  match do |page|
    page.should have_selector('div.alert.alert-notice', opts)
  end
end

RSpec::Matchers.define :have_field_error do |field|
  match do |page|
    page.should have_selector("div.field_with_errors > ##{field}")
  end
end
