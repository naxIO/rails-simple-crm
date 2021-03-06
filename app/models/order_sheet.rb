class OrderSheet < ActiveRecord::Base
extend Enumerize

  has_paper_trail 

  has_many :order_sheet_lines, :dependent => :destroy
  has_many :periods, :dependent => :nullify
  accepts_nested_attributes_for :order_sheet_lines, :allow_destroy => true, reject_if: proc { |attributes| attributes['price'].blank? }

  enumerize :status, in: [:draft, :active , :cancel]

  validates :title, presence: true
  validates :send_to, presence: true
  validates :order_date, presence: true
  validates :company_info, presence: true


  def total_price
    price = 0
    self.order_sheet_lines.each do |l|
      price += l.price
    end
    return price
  end

  def toggle_status
    case self.status
    when "draft" then
      self.update_attributes(status: :active)
    when "active" then
      self.update_attributes(status: :cancel)
    when "cancel" then
      self.update_attributes(status: :draft)
    else
      raise "invalid status #{self.status}"
    end
  end


  def self.to_csv
    CSV.generate do |csv|
      csv << column_names + ["total_price"]

      all.each do |l|

        values = l.attributes.values_at(*column_names)

        if l.order_sheet_lines.present?
          osl = l.order_sheet_lines
          values = values + [osl.sum(:price)]
        else
          values = values + [0]
        end
        csv << values
      end
    end
  end

end
