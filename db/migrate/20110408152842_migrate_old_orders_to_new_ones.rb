class MigrateOldOrdersToNewOnes < ActiveRecord::Migration
  def self.up
    
    OldOrder.all.each do |oo|
      o = Order.new
      o.user = oo.user
      o.document_number = oo.document_number
      o.status_constant = oo.status_constant
      o.created_at = oo.created_at
      o.shipping_address = oo.shipping_address
      o.billing_address = oo.billing_address
      o.payment_method = oo.payment_method
      o.shipping_taxes = oo.shipping_taxes
      o.direct_shipping = (oo.direct_shipping? ? true : false)
      o.shipping_cost = oo.shipping_rate.total_cost.rounded
      
      if o.save
        puts "order #{o.id} saved"
      else
        puts "order not saved:"
        puts o.errors.full_messages
      end
      
      if oo.invoice
        puts "order #{o.id} has an invoice, importing lines:"
        oo.invoice.lines.each do |il|
          il.order_id = o.id
          il.product_id = Product.where(:name => il.text).first.id
          il.single_untaxed_price = Product.where(:name => il.text).first.gross_price.rounded          
          puts " --- ARGH, no product!" if il.product_id.nil?
          if il.save
            puts " --- invoice line #{il.id} saved"
          else
            puts " --- invoice line #{il.id} could not be changed"
          end
        end
        o.invoice = oo.invoice
      end
      
      
      
      puts " +++"
      
    end
    
  end

  def self.down
  end
end
