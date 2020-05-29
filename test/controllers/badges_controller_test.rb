require 'test_helper'

class BadgesControllerTest < ActionDispatch::IntegrationTest

  setup do
    @badge = badges(:one)
    @badge.card = fixture_file_upload('images/design2.pdf', 'application/pdf')
    @badge.picture = fixture_file_upload('images/badger_300r.jpg', 'image/jpg')
    @badge.save

    @user = users(:user)
    sign_in @user
  end

  test 'guesswho available to nonauthenticated users' do
    sign_out @user
    get guesswho_badges_url
    assert_response :success
    assert_not_nil assigns(:badges)
  end

  test 'should get index' do
    get badges_url
    assert_response :success
    assert_not_nil assigns(:badges)
  end

  test 'should get new' do
    get new_badge_url
    assert_response :success
  end

  test 'should create badge' do
    assert_difference('Badge.count') do
      post badges_url, params: {
        badge: {
          department: @badge.department,
          employee_id: @badge.employee_id,
          first_name: @badge.first_name,
          last_name: @badge.last_name,
          title: @badge.title
        }
      }
    end

    assert_redirected_to camera_badge_path(assigns(:badge))
  end

  test 'should not create empty badge' do
    assert_no_difference('Badge.count') do
      post badges_url, params: {
        badge: {
          department: 'huzzah'
        }
      }
    end
    assert_template :new
  end

  test 'should show badge' do
    get badge_url(@badge)
    assert_response :success
  end

  test 'should get edit' do
    get edit_badge_url(@badge)
    assert_response :success
  end

  test 'should update badge' do
    patch badge_url(@badge), params: {
      badge: {
        department: @badge.department,
        employee_id: @badge.employee_id,
        name: @badge.name,
        picture: @badge.picture,
        title: @badge.title
      }
    }
    assert_redirected_to badge_path(assigns(:badge))
  end

  test 'should destroy badge' do
    assert_difference('Badge.count', -1) do
      delete badge_url(@badge)
    end

    assert_redirected_to badges_path
  end

  test 'should generate badge' do
    get generate_badge_url(@badge)
    assert_redirected_to badge_path(@badge)
    assert_match "been generated", flash[:notice]
  end

  test 'should print badge' do
    get print_badge_url(@badge)

    assert_redirected_to badge_path(assigns(:badge))
  end

  test 'should crop image' do
    @badge.picture = File.new(Rails.root.join('app', 'assets', 'images', 'badger_300r.jpg').to_s)
    @badge.save
    get crop_badge_url(@badge, format: :json), params: { x: 1, y: 1, w: 10, h: 10 }

    assert_response :success
  end
end
