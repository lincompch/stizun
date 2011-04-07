class OrderLine < StaticDocumentLine
  belongs_to :order
  belongs_to :product
  belongs_to :invoice
end