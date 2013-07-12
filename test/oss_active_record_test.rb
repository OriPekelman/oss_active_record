require_relative './test_helper'

class OssActiveRecordTest < ActiveSupport::TestCase
  test "OssActiveRecord is a module" do
    assert_kind_of Module, OssActiveRecord
  end
end
