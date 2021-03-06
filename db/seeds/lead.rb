require "csv"
require 'kconv'
require 'tempfile'

def tel_encode(input)
    i = input.to_s.gsub /[\u30FC]|[\u2010]|[\u2011]|[\u2013]|[\u2014]|[\u2015]|[\u2212]|[\uFF70]/ , "-"
    i = i.gsub "/" , ""
    i = i.gsub "~" , ""
    i = i.gsub "." , ""
    i = i.gsub "、" , ""
    i = i.gsub /(\d{2,4})[\(（\-\?](\d{2,4})[）\?\-\)](\d{2,4})/ , "\\1-\\2-\\3"
    i = i.gsub "（", ""
    i = i.strip
    i = NKF.nkf('-m0Z1 -w', i)
    return i
end

def split_address(address, prefecture)
  rex = /(...??[都道府県])((?:旭川|伊達|石狩|盛岡|奥州|田村|南相馬|那須塩原|東村山|武蔵村山|羽村|十日町|上越|富山|野々市|大町|蒲郡|四日市|姫路|大和郡山|廿日市|下松|岩国|田川|大村)市|.+?郡(?:玉村|大町|.+?)[町村]|.+?市.+?区|.+?[市区町村])(.+)/

  adp =  address.match(rex)
  if adp.present?
    return adp.captures
  end

  rex2 = /((?:旭川|伊達|石狩|盛岡|奥州|田村|南相馬|那須塩原|東村山|武蔵村山|羽村|十日町|上越|富山|野々市|大町|蒲郡|四日市|姫路|大和郡山|廿日市|下松|岩国|田川|大村)市|.+?郡(?:玉村|大町|.+?)[町村]|.+?市.+?区|.+?[市区町村])(.+)/

  ad =  address.match(rex2)
  if ad.present?
    return ad.captures.unshift(prefecture)
  end
end

def create_lead(r)
  lead = Lead.new(:name => r[:client_name],:zipcode => r[:zip_code])
  lead.tel = tel_encode(r[:tel])
  lead.fax = tel_encode(r[:fax])
  lead.tag_list.add(r[:category])
  lead.tag_list.add("テレアポ用リスト")
  lead.tag_list.add("wamnet #{Time.current.to_s(:dash_date)}追加")
  lead.zipcode.gsub! "〒",""
  lead.corporation_name =  r[:company_name]
  lead.url = r[:url]
  return lead
end

unless ENV["prefecture"]
  p "it need prefecture"
  exit
end


table = CSV.table('db/lead_list.csv',encoding: "Windows-31J:UTF-8")
table.each do |r|
  #事業所名が空白の場合、スキップ
  if r[:client_name].blank?
    next
  end

  #もし電話番号で発見できない場合、新しく作成
  lead = Lead.find_by(tel: tel_encode(r[:tel]))
  lead = create_lead(r) if lead.blank?

  address = split_address(r[:address],ENV["prefecture"])
  if address.blank?
    p "no address #{r[:address]}"
    next
  end
  
  #住所情報の更新
  lead.prefecture = address[0]
  lead.city = address[1]
  lead.street = address[2]

  memo = <<EOL
  ------- wamnet #{Time.current.to_s(:jp_date)}更新---------------------
  カテゴリ：#{r[:category]}
  管理者：#{r[:client_person]}
  管理者の役職：#{r[:client_post]}
  法人の種類：#{r[:company]}
  法人名：#{r[:company_name]}
  法人の住所：#{r[:company_address]}
  法人の電話番号：#{r[:company_tel]}
  法人のFAX：#{r[:company_fax]}
  法人代表者：#{r[:company_person]}
  法人代表者の役職名：#{r[:company_post]}
  ----------------------------------------------------------- 
EOL
  lead.memo = lead.memo.present? ? lead.memo << memo : memo

  lead.tag_list.add("wamnet #{Time.current.to_s(:dash_date)}更新")

  unless lead.save
    p lead.errors.full_messages.inspect
  end
end
