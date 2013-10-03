json.extract! @datatables.getIData, :sEcho, :iTotalRecords, :iTotalDisplayRecords

comp = @datatables.getCompanies.map do |company|

[
        "<a href='"+ url_for(:action=>"edit", :id => company.id) + "'>"+ company.client_name.slice(0,25) + "</a>",
        get_status_name(company.status_id),
        company.client_person,
        company.updated_at.strftime('%Y/%m/%d'),
        get_user_name(company.sales_person),
        company.industry.name,
        company.bill,
        company.chance,
        company.campaign.name,
        get_user_name(company.created_by),
        get_user_name(company.updated_by),
        company.tel,
        company.fax,
        contactAsHtml(company),
        '<input type="checkbox" name="check' + company.id.to_s + '" value="' + company.id.to_s + '">'
]
end

json.aaData comp
