module ApplicationHelper
  
  def simple_date(time)
    if time.present?
      return time.strftime("%Y年%m月%d日 %H時%M分%S秒")
    end
  end

  def hbr(str)
    h(str).gsub(/(\r\n?)|(\n)/, "<br />").html_safe
  end
  
  def convert_min(minute)
    if(minute.present?)
     return (minute / 60).floor.to_s + "時間" + (minute % 60).floor.to_s + "分"
    else
     return 0
    end
  end
  
  def check_img_src(bool)
    if bool == true
      return "/img/check.png"
    else
      return "/img/cross.png"
    end
  end

  def link_to_switch_flg model , attr
    bool = model.read_attribute(attr)
    model_name =  model.class.name.underscore

    bool_locale = bool == true ? ".flag_on" : ".flag_off"
    locale = "activerecord.flags." + model_name + "." + attr.to_s + bool_locale

    text = I18n.t locale
    span_tag =  %Q{<span class="flag_#{bool}">#{text}</span>}

    return link_to span_tag.html_safe , {:controller => model_name.pluralize.gsub(" ","_"), :action => "flag",  :id => model.id, :type => attr, :format => "js"}, :remote => true,  id: %Q{#{model_name}_#{attr}_#{model.id}}
  end

  
  def check_m_img(bool)
    if bool === true
      src =  "/img/check-m.png"
      order = "a"
    elsif bool === false
      src = "/img/cross-m.png"
      order = "b"
    else
      raise "type Error check_m_img"
    end   

    img_tag =  "<img src='" + src + "'/> <span style='display:none'>" + order + "</span>"    
    return img_tag.html_safe
  end

end
