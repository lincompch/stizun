class AccountTransaction < ActiveRecord::Base

  validates_presence_of :amount
  validates_numericality_of :amount
  
  
  belongs_to :credit_account, :polymorphic => true
  belongs_to :debit_account, :polymorphic => true
  
  # The transfer method registers a transaction between two
  # accounts. It runs inside an ActiveRecord transaction.
  # Transfers should never be done manually, always with this
  # method!
  def self.transfer(credit_account, debit_account, amount, note = nil, target_object = nil)
    
    if credit_account == debit_account
      raise ArgumentError, "The accounts must be different."
    end
    
    AccountTransaction.transaction do
      at = self.new
      at.credit_account = credit_account
      at.debit_account = debit_account
      at.amount = amount
      at.note = note
      at.target_object = target_object unless target_object.nil?
      if at.save
        JournalEntry.add(at.credit_account.name, at.debit_account.name, at.note, at.amount)
        History.add("Account transfer: #{at.credit_account.name}/#{at.debit_account.name}, #{at.amount}. Note: #{at.note}", History::ACCOUNTING)
        return true
      else
        return false
      end
    end
  end
  
  def target_object
    if [self.target_object_type, self.target_object_id].include?(nil)
      return nil
    else
      self.target_object_type.constantize.find(self.target_object_id)
    end
  end
  
  def target_object=(object)
    self.target_object_type = object.class.name
    self.target_object_id = object.id
  end
  
  def self.find_by_target_object(object)
    self.find(:first, :conditions => { :target_object_type => object.class.name, 
                                       :target_object_id => object.id } )
  end
  
end