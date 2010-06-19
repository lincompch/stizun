class Admin::AccountsController < Admin::BaseController

  def index
    #@accounts = Account.all
    
    @assets_accounts = Account.find(:all, :conditions => { :type_constant => Account::ASSETS })
    @liabilities_accounts = Account.find(:all, :conditions => { :type_constant => Account::LIABILITIES })
    @income_accounts = Account.find(:all, :conditions => { :type_constant => Account::INCOME })
    @expense_accounts = Account.find(:all, :conditions => { :type_constant => Account::EXPENSE })
    
    
  end
  

  def show
    @account = Account.find(params[:id])
  end
end