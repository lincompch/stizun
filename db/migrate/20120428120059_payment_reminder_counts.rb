class PaymentReminderCounts < ActiveRecord::Migration
  def up
    add_column :invoices, :reminder_count, :integer, :default => 0
    add_column :invoices, :last_reminded_at, :datetime, :default => nil
  end

  def down
    remove_column :invoices, :reminder_count
    remove_column :invoices, :last_reminded_at
  end
end
