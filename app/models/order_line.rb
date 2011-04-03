class OrderLine < StaticDocumentLine
  belongs_to :order
  belongs_to :product
end