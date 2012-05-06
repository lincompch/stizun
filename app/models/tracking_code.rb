class TrackingCode < ActiveRecord::Base

  belongs_to :order
  belongs_to :shipping_carrier

  #validates_presence_of :shipping_carrier_id, :tracking_code

  # Pretty primitive, but mostly effective provided that tracking_base_url end
  # in a query string (e.g. http://www.foo.com/tracking?blah=lala&foo=)
  def tracking_url
    if is_complete?
      return "#{shipping_carrier.tracking_base_url}#{tracking_code}"
    else
      return false
    end
  end

  def is_complete?
    !tracking_code.blank? && !shipping_carrier_id.nil?    
  end


end

