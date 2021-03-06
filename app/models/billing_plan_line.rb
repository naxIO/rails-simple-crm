# == Schema Information
#
# Table name: billing_plan_lines
#
#  id              :integer          not null, primary key
#  bill_date       :date             not null
#  accural_date    :date             not null
#  memo            :text
#  billing_plan_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  price           :integer
#

class BillingPlanLine < ActiveRecord::Base

  has_paper_trail 
  belongs_to :billing_plan

  validates :bill_date, presence: true  
  validates :accural_date, presence: true  
  validates :price, presence: true,  
    numericality: {only_integer: true, greater_than: 0}

  scope :sales, lambda{|date|
    from =  date.beginning_of_month 
    to =  date.end_of_month.tomorrow
    joins(:billing_plan).where(accural_date: from...to).where("billing_plans.status = ?","completed").order(:accural_date)
  }


  def company_name
    return self.billing_plan.company.client_name
  end

end
