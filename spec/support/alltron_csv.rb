
class AlltronTestHelper

  def self.import_from_file(filename)
    require 'lib/alltron_util'
    AlltronUtil.import_supply_items(Rails.root + filename)
  end

end