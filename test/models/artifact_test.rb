require 'test_helper'

class ArtifactTest < ActiveSupport::TestCase
  test "reorders on save" do
    side = sides(:one)
    assert side.artifacts.last.order == 40
    artifact = side.artifacts.create(name: 'move_up_more', order: 15, description: 'move up a little more', value: 5)
    artifact.save
    assert side.artifacts.last.order == 50
  end

  test "reorders on delete" do
    side = sides(:one)
    assert side.artifacts.last.order == 40
    side.artifacts.second.destroy
    assert side.artifacts.last.order == 30
  end
end
