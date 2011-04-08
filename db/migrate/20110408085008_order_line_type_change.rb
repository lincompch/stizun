class OrderLineTypeChange < ActiveRecord::Migration
  def self.up
    DocumentLine.connection.execute("update document_lines set type='OldOrderLine' where type='OrderLine'")
  end

  def self.down
    DocumentLine.connection.execute("update document_lines set type='OrderLine' where type='OldOrderLine'")
  end
end
