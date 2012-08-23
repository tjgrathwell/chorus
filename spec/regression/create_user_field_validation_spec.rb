require File.join(File.dirname(__FILE__), '../integration/spec_helper')

describe "creating a user" do
  before(:each) do
    login('edcadmin', 'secret')
  end

  it "should not create a user whose user id has a white space" do

    create_new_user_page
    first_name = Forgery::Name.first_name
    last_name = Forgery::Name.last_name
    wait_for_ajax
    fill_in 'firstName', :with =>first_name
    fill_in 'lastName', :with => last_name
    username = "#{first_name}#{last_name}"
    fill_in 'username', :with => "user name"
    fill_in 'email', :with => "#{username}@email.com"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    click_submit_button
    wait_for_ajax
    page.should have_content ("Username is invalid")
    fill_in 'username', :with => username
    click_submit_button
    wait_for_ajax
    wait_until { current_route == "/users" }
    click_link("#{first_name} #{last_name}")
    page.find("div.department").should have_content("Greenplum")
    page.find("div.title").should have_content("QA")
    page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should not let the admin create user without a username" do
    create_new_user_page
    wait_for_ajax
    first_name = Forgery::Name.first_name
    last_name = Forgery::Name.last_name
    fill_in 'firstName', :with =>first_name
    fill_in 'lastName', :with => last_name
    username = "#{first_name}#{last_name}"
    fill_in 'username', :with => ""
    fill_in 'email', :with => "#{username}@email.com"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    click_submit_button
    wait_for_ajax
    field_errors.should_not be_empty

    fill_in 'username', :with => username
    click_submit_button
    wait_for_ajax
    wait_until { current_route == "/users" }
    click_link("#{first_name} #{last_name}")
    page.find("div.department").should have_content("Greenplum")
    page.find("div.title").should have_content("QA")
    page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should create a user with max length for username field" do

      create_new_user_page
      wait_for_ajax
      first_name = Forgery::Name.first_name
      last_name = Forgery::Name.last_name
      fill_in 'firstName', :with =>first_name
      fill_in 'lastName', :with => last_name
      username = "#{first_name}#{last_name}"
      fill_in 'username', :with => "username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12username12123456"
      fill_in 'email', :with => "some@email.com"
      fill_in 'password', :with => "secret"
      fill_in 'passwordConfirmation', :with => "secret"
      fill_in 'dept', :with => "Greenplum"
      fill_in 'title', :with => "QA"
      click_submit_button
      wait_for_ajax
      wait_until { current_route == "/users" }
      click_link("#{first_name} #{last_name}")
      page.find("div.department").should have_content("Greenplum")
      page.find("div.title").should have_content("QA")
      page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should not allow an admin to create a user without a first name" do

      create_new_user_page
      wait_for_ajax
      first_name = Forgery::Name.first_name
      last_name = Forgery::Name.last_name
      fill_in 'firstName', :with => ""
      fill_in 'lastName', :with => ""
      username = "#{first_name}#{last_name}"
      fill_in 'username', :with => "#{first_name}#{last_name}"
      fill_in 'email', :with => "#{username}@email.com"
      fill_in 'password', :with => "secret"
      fill_in 'passwordConfirmation', :with => "secret"
      fill_in 'dept', :with => "Greenplum"
      fill_in 'title', :with => "QA"
      click_submit_button
      wait_for_ajax
      field_errors.should_not be_empty

      fill_in 'firstName', :with => first_name
      fill_in 'lastName', :with =>last_name
      click_submit_button
      wait_for_ajax

      wait_until { current_route == "/users" }
      click_link("#{first_name} #{last_name}")
      page.find("div.department").should have_content("Greenplum")
      page.find("div.title").should have_content("QA")
      page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should not allow to create a user with no matching password or password less than 5 characters" do

    visit("/#/users/new")
    wait_for_ajax
    first_name = Forgery::Name.first_name
    last_name = Forgery::Name.last_name
    fill_in 'firstName', :with =>first_name
    fill_in 'lastName', :with => last_name
    username = "#{first_name}#{last_name}"
    fill_in 'username', :with => username
    fill_in 'email', :with => "#{username}@email.com"
    fill_in 'password', :with => "secre"
    fill_in 'passwordConfirmation', :with => "secre"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    page.find("button[type=submit]").click
    page.should have_content("Password must be at least 6 characters")

    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secre"
    page.find("button[type=submit]").click
    field_errors.should_not be_empty

    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    page.find("button[type=submit]").click
    wait_until { current_route == "/users" }
    click_link("#{first_name} #{last_name}")
    page.find("div.department").should have_content("Greenplum")
    page.find("div.title").should have_content("QA")
    page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should not let the admin create a user with a wrong email address" do

    create_new_user_page
    wait_for_ajax
    first_name = Forgery::Name.first_name
    last_name = Forgery::Name.last_name
    fill_in 'firstName', :with =>first_name
    fill_in 'lastName', :with => last_name
    username = "#{first_name}#{last_name}"
    fill_in 'username', :with => username
    fill_in 'email', :with => "someemail@email"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    page.find("button[type=submit]").click
    field_errors.should_not be_empty

    fill_in 'email', :with => " "
    page.find("button[type=submit]").click
    field_errors.should_not be_empty

    fill_in 'email', :with => "someemail@email.com"
    page.find("button[type=submit]").click
    wait_until { current_route == "/users" }
    click_link("#{first_name} #{last_name}")
    page.find("div.department").should have_content("Greenplum")
    page.find("div.title").should have_content("QA")
    page.find("h1").should have_content("#{first_name} #{last_name}")

  end

  it "should not let the admin create a user without the required fields filled up" do

    create_new_user_page
    wait_for_ajax
    click_submit_button
    wait_for_ajax
    field_errors.should_not be_empty

  end

  it "should let an admin create a user as an admin" do

    create_new_user_page
    wait_for_ajax
    first_name = Forgery::Name.first_name
    last_name = Forgery::Name.last_name
    username = "#{first_name}#{last_name}"
    department = Forgery::Name.industry
    title = Forgery::Name.title

    fill_in 'firstName', :with =>first_name
    fill_in 'lastName', :with => last_name
    fill_in 'username', :with => username
    fill_in 'email', :with => "someemail@email.com"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    check "Make this user an administrator"
    click_submit_button

    wait_until { current_route == "/users" }
    click_link("#{first_name} #{last_name}")
    page.should have_content "Administrator"
    page.find("h1").should have_content("#{first_name} #{last_name}")


  end

  it "allows user to edit their own info" do

    create_new_user_page
    wait_for_ajax
    fill_in 'firstName', :with => "edit"
    fill_in 'lastName', :with => "user"
    fill_in 'username', :with => "edituser"
    fill_in 'email', :with => "someemail@email.com"
    fill_in 'password', :with => "secret"
    fill_in 'passwordConfirmation', :with => "secret"
    fill_in 'dept', :with => "Greenplum"
    fill_in 'title', :with => "QA"
    click_submit_button

    wait_until { current_route == "/users" }
    within(".list") do
      click_link "edit user"
    end
    page.find("h1").should have_content "edit user"

    logout
    login('edituser', 'secret')
    go_to_user_list_page
    within(".list") do
      click_link "edit user"
    end
    page.find("h1").should have_content "edit user"
    click_link "Edit Profile"
    wait_for_ajax
    sleep(2)
    page.find("h1").should have_content "edit user"
    fill_in 'firstName', :with => "edited"
    fill_in 'lastName', :with => "users"
    fill_in 'email', :with => "some1email@email.com"
    fill_in 'dept', :with => "Greenplum edit"
    fill_in 'title', :with => "QA edit"
    click_submit_button
    wait_for_ajax
    page.find("h1").should have_content "edited users"
    page.should have_content "some1email@email.com"
    page.should have_content "Greenplum edit"
    page.should have_content "QA edit"

  end

end