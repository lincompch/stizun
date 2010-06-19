class Admin::AccountTransactionsController < Admin::BaseController

  def index
   @account_transactions = AccountTransaction.all
  end
  

  # This method is only called 'new' to fit in with other RESTful methods.
  # It actually works slightly differently than the other methods of this kind
  # because it prepares no object for the new.html.erb view. Instead, that view
  # posts to a modified create method which makes sure that transactions
  # are handled through the safe AccountTransaction.transfer() method, not directly.
  def new
    @account_transaction = AccountTransaction.new
    @last_transactions = AccountTransaction.find(:all, :limit => 5, :order => 'created_at DESC')
  end
  
  
  # This is not a typical RESTful create method. Instead, it assembles the 
  # necessary parameters for a custom AccountTransaction.transfer method by
  # hand.
  def create
    @last_transactions = AccountTransaction.find(:all, :limit => 5)

    @account_transaction = AccountTransaction.new(params[:account_transaction])
    credit_account = Account.find(@account_transaction.credit_account_id) #Account.find(params[:credit_account_id])
    debit_account = Account.find(@account_transaction.debit_account_id) #Account.find(params[:debit_account_id])
    note = @account_transaction.note #params[:note]
    amount = @account_transaction.amount #params[:amount]

    if AccountTransaction.transfer(credit_account, debit_account, amount, note)
      flash[:notice] = "Transaction saved successfully."
      render :action => 'new'
    else
      flash[:error] = "The transaction was not saved!"
      render :action => 'new'
    end
  end
  
end