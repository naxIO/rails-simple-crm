class PublicBillLine < ActiveRecord::Base

  has_paper_trail 
  belongs_to :public_bill

  validates :unit_price, presence:true, numericality: {only_integer: true}
  validates :name, presence: true
  validates :quantity, presence:true, numericality: {only_integer: true}
  validates :tax_rate, presence: true, numericality: {only_integer: true, greater_than_or_equal_to: 0, less_than: 10}
  

  def tax_exclude_price
    unit_price.to_i * quantity.to_i
  end

  def tax_price
    if tax_rate.present? and tax_exclude_price.present?
      return tax_exclude_price * tax_rate / 100
    else
      return 0
    end
  end

  def tax_include_price
    tax_exclude_price + tax_price
  end

  def total_price
    tax_include_price
  end
end
