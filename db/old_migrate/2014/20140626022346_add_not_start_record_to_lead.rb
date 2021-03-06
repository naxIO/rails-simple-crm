class AddNotStartRecordToLead < ActiveRecord::Migration
  def up
    add_column :leads, :corporation_name, :string
    LeadHistory.delete_all
    Lead.delete_all
    companies = Company.where(active_st: [:notstart,:pending, :active_c, :active_b, :active_a])
    companies.each do |c|
      lead = Lead.new
      lead.name = c.name
      lead.tel = c.tel
      lead.fax = c.fax
      lead.email = c.mail
      lead.person_name = c.client_person
      case c.campaign.id
      when 1 then
        lead.campaign = "fax"
      when 2 then
        lead.campaign = "homepage"
      when 3 then
        lead.campaign = "tel"
      when 4 then
        lead.campaign = "introduce"
      when 5 then
        lead.campaign = "introduce"
      when 7 then
        lead.campaign = "homepage"
      when 99 then
        lead.campaign = "other"
      when 100 then
        lead.campaign = "tel"
      when 112 then
        lead.campaign = "tel"
      when 6 then
        lead.campaign = "tel"
      else
        lead.campaign = "fax"
      end
      lead.campaign_detail = c.campaign.name

      if c.clients.present?
        lead.person_kana = c.clients.first.last_kana
      end

      if c.zipcode.blank?
      else
        lead.zipcode = c.zipcode.strip.gsub(/(\d{3})(\d{4})/,'\1-\2').gsub("‐","-")
      end
      lead.prefecture = c.prefecture
      lead.city = c.city
      lead.street = c.address
      lead.building = c.building

      nego = c.negos.first
      if nego.present?
        if nego.status.present?
          lead.memo = "旧ステータス;" +  nego.status.name + "\n"
        end
      end

      if lead.memo.present?
        lead.memo = lead.memo + "旧確度:" + c.active_st.text if c.active_st.present?
      else
        lead.memo = "旧確度:" + c.active_st.text if c.active_st.present?
      end


      c.contacts.each do |con|
        his = LeadHistory.new
        his.memo = con.memo
        his.lead_history_status_id = 1
        his.approach_day = con.created_at
        if c.negos.first.present?
          his.user_id = c.negos.first.user_id
        else
          puts c.id
          his.user_id = 1
        end
        lead.lead_histories << his
        saving lead,c
      end

      saving lead,c

    end
  end

  def saving lead,c
      if lead.save
      else
        puts "-------------------------------------"
        puts c.id
        puts lead.errors.full_messages.inspect
        puts "-------------------------------------"
      end
  end

  def down
    remove_column :leads, :corporation_name
    LeadHistory.delete_all
    Lead.delete_all
  end

end
