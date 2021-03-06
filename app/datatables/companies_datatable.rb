class CompaniesDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end
  
  def getCompanies
    return @companies
  end

  def getIData(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Company.count,
      iTotalDisplayRecords: companies.total_entries,
    }
  end

  def companies
    @companies ||= fetch_companies
  end

  def all
    c = fetch_companies
    c.page(1)
    c.per_page(10000)
  end

  def fetch_companies
    companies = Company.joins(:negos).order("#{sort_column} #{sort_direction}")
    companies = companies.page(page).per_page(per_page)
    if params[:sSearch].present?
      companies = companies.where("client_name like :search", search: "%#{params[:sSearch]}%")
    elsif params[:company]['client_name'].present?
      companies = companies.where("client_name like :search", search: "%#{params[:company]['client_name']}%")      
    end
    
    
    p_comp = params[:company]
    if p_comp['prefecture'].present?
      companies = companies.where("prefecture like ?","%" + p_comp['prefecture'] + "%")
    end
    if p_comp['industry_id'].present?
      companies = companies.where(:industry_id => p_comp['industry_id'])
    end
    if p_comp['city'].present?
      companies = companies.where("city like ?","%" + p_comp['city'] + "%")
    end

    if p_comp['tel'].present?
      companies = companies.where("tel like ?","%" + p_comp['tel'] + "%")
    end

    if params['saler'].present?
      companies = companies.sales_where(params['saler'])
    end

    if params['stage'].present?
      companies = companies.where("negos.status_id = ?",  params['stage'])
    elsif params[:rank].present?
      status_array = Status.find_all_by_rank(params['rank'])
      companies = companies.where(negos: {status_id: status_array})
    end

    if p_comp['active_st'].present?
      companies = companies.where(:active_st => p_comp['active_st'])
    end

    if p_comp['campaign_id'].present?
      companies = companies.where(:campaign_id => p_comp['campaign_id'])
    end
    if p_comp['created_by'].present?
      companies = companies.where(:created_by => p_comp['created_by'])
    end
    if p_comp['updated_by'].present?
      companies = companies.where(:updated_by => p_comp['updated_by'])
    end
    if p_comp['created_at'].present?
      companies = companies.where(:created_at => Date.parse(p_comp['created_at']).beginning_of_day..Date.parse(p_comp['created_at']).end_of_day)
    end
    if p_comp['updated_at'].present?
      companies = companies.where(:updated_at => Date.parse(p_comp['updated_at']).beginning_of_day..Date.parse(p_comp['updated_at']).end_of_day)
    end
    
    return companies
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    sort_hash = ["client_name" , "status_id","active_st", "client_person", "updated_at", 
      "sales_person","industry_id", "chance","lead","created_by", "updated_by", "tel", "fax", "prefecture","city"]
    if params[:iSortCol_0].present?
      sort_column = sort_hash.fetch(params[:iSortCol_0].to_i)
    else
      sort_column = "updated_at"
    end
    Rails.logger.debug("iSortCol Equal " + params[:iSortCol_0].to_s + " and sort_column = " + sort_column.to_s)
    return sort_column
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
