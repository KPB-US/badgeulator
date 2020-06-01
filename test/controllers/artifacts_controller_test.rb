require 'test_helper'

class ArtifactsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @artifact = artifacts(:one)
    @user = users(:admin)
    sign_in @user
  end

  test 'non-admin users cannot perform any actions on artifacts' do
    sign_out @user
    [:user, :none].each do |user|
      @user = users(:user)
      sign_in @user

      [artifacts_url, new_artifact_url, artifact_url(@artifact), edit_artifact_url(@artifact)].each do |action|
        get action
        assert_response :redirect, "#{user} should have been redirected on #{action}"
        assert_redirected_to root_path, "#{user} should have been redirected to root_path on #{action}"
        assert_match 'not authorized', flash[:alert], "#{user} should not have been authorized on #{action}"
      end

      post artifacts_url, params: {
        artifact: {
          description: @artifact.description,
          name: @artifact.name,
          order: @artifact.order,
          side_id: @artifact.side_id,
          value: @artifact.value
        }
      }
      assert_response :redirect, "#{user} should have been redirected on :create"
      assert_redirected_to root_path, "#{user} should have been redirected to root_path on :create"
      assert_match 'not authorized', flash[:alert], "#{user} should not have been authorized on :create"

      patch artifact_url(@artifact.id), params: {
        artifact: {
          description: @artifact.description,
          name: @artifact.name,
          order: @artifact.order,
          side_id: @artifact.side_id,
          value: @artifact.value
        }
      }
      assert_response :redirect, "#{user} should have been redirected on :update"
      assert_redirected_to root_path, "#{user} should have been redirected to root_path on :update"
      assert_match 'not authorized', flash[:alert], "#{user} should not have been authorized on :update"

      delete artifact_url(@artifact.id)
      assert_response :redirect, "#{user} should have been redirected on :delete"
      assert_redirected_to root_path, "#{user} should have been redirected to root_path on :delete"
      assert_match 'not authorized', flash[:alert], "#{user} should not have been authorized on :delete"
    end
  end

  test 'should get index' do
    get artifacts_url
    assert_response :success
    assert_not_nil assigns(:artifacts)
  end

  test 'should get new' do
    get new_artifact_url
    assert_response :success
  end

  test 'should create artifact' do
    assert_difference('Artifact.count') do
      post artifacts_url, params: {
        artifact: {
          description: @artifact.description,
          name: @artifact.name,
          order: @artifact.order,
          side_id: @artifact.side_id,
          value: @artifact.value
        }
      }
    end

    assert_redirected_to artifact_path(assigns(:artifact))
  end

  test 'should show artifact' do
    get artifact_url(@artifact.id)
    assert_response :success
  end

  test 'should get edit' do
    get artifact_url(@artifact.id)
    assert_response :success
  end

  test 'should update artifact' do
    patch artifact_url(@artifact.id), params: {
      artifact: {
        description: @artifact.description,
        name: @artifact.name,
        order: @artifact.order,
        side_id: @artifact.side_id,
        value: @artifact.value
      }
    }
    assert_redirected_to side_path(assigns(:artifact).side)
  end

  test 'should destroy artifact' do
    assert_difference('Artifact.count', -1) do
      delete artifact_url(@artifact.id)
    end

    assert_redirected_to artifacts_path
  end

  test 'copy properties' do
    a = artifacts(:two)
    get copy_props_artifact_url(a.id)
    assert_redirected_to artifacts_url
    assert_not_nil a.properties.find_by(name: 'nop')
  end

  test 'copy properties does not overwrite existing' do
    a = artifacts(:two)
    get copy_props_artifact_url(a)
    assert_redirected_to artifacts_url
    assert_equal a.properties.find_by(name: 'up').value, '10'
  end

  test 'updating an artifact re-renders the design sample' do
    before_sample_updated_at = @artifact.side.design.sample_updated_at

    patch artifact_url(@artifact.id), params: {
      artifact: {
        description: @artifact.description,
        name: @artifact.name + ' updated',
        order: @artifact.order,
        side_id: @artifact.side_id,
        value: @artifact.value
      }
    }

    after_sample_updated_at = Design.find(@artifact.side.design.id).sample_updated_at
    assert_not_equal before_sample_updated_at, after_sample_updated_at
  end

  test 'copying properties re-renders the design sample' do
    before_sample_updated_at = @artifact.side.design.sample_updated_at

    a = artifacts(:two)
    get copy_props_artifact_url(a)
    
    after_sample_updated_at = Design.find(@artifact.side.design.id).sample_updated_at
    assert_not_equal before_sample_updated_at, after_sample_updated_at
  end

  test 'adding a property re-renders the design sample' do
    before_sample_updated_at = @artifact.side.design.sample_updated_at

    post artifacts_url, params: {
      artifact: {
        description: @artifact.description,
        name: @artifact.name,
        order: @artifact.order,
        side_id: @artifact.side_id,
        value: @artifact.value
      }
    }

    after_sample_updated_at = Design.find(@artifact.side.design.id).sample_updated_at
    assert_not_equal before_sample_updated_at, after_sample_updated_at
  end
end
