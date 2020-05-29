require "application_system_test_case"

class GuesswhosTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit guesswhos_url
  #
  #   assert_selector "h1", text: "Guesswho"
  # end

  test "playing guesswho" do
    add_badges

    johns_name = ".thumbnail.name-tag[data-id='98765']"
    johns_pix = ".thumbnail.person[data-id='98765']"

    janes_name = ".thumbnail.name-tag[data-id='98766']"
    janes_pix = ".thumbnail.person[data-id='98766']"

    # has a photo for john and jane
    visit guesswho_badges_url
    assert_selector johns_pix
    assert_selector janes_pix

    # has a caption for john and jane
    assert_selector johns_name
    assert_selector janes_name

    # dragging janes name to johns photo causes an alert
    page.execute_script <<-EOS
      var dragSource  = document.querySelector("#{janes_name}");
      var dropTarget  = document.querySelector("#{johns_pix}");
      
      dragMock
        .dragStart(dragSource)
        .drop(dropTarget);    
    EOS
    # johns photo is marked as wrong "missed"
    find ".missed#{johns_pix}"
    assert_selector 'div.scoreboard', text: '0%, GUESSES 1'

    # dragging johns name to johns photo works
    page.execute_script <<-EOS
      var dragSource  = document.querySelector("#{johns_name}");
      var dropTarget  = document.querySelector("#{johns_pix}");
      
      dragMock
        .dragStart(dragSource)
        .drop(dropTarget);    
    EOS
    sleep 0.3
    assert_selector 'div.scoreboard', text: '50%, GUESSES 2'
    # johns name is marked as used
    assert_selector ".used#{johns_name}"
    # johns photo is now marked as correct
    assert_selector ".correct#{johns_pix}"

  end

  private 

  def add_badges
    john = Badge.create(
      id: 98765,
      first_name: 'John',
      last_name: 'Doe',
      title: 'john job title',
      department: 'john department',
      employee_id: 98765,
      picture: File.open('test/fixtures/images/badger_300r.jpg'),
      card: File.open('test/fixtures/images/design2.pdf')
    )

    jane = Badge.create(
      id: 98766,
      first_name: 'Jane',
      last_name: 'Doe',
      title: 'jane job title',
      department: 'jane department',
      employee_id: 98766,
      picture: File.open('test/fixtures/images/badger_300r.jpg'),
      card: File.open('test/fixtures/images/design2.pdf')
    )

    [john, jane]
  end

end
