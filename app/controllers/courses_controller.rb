class CoursesController < ApplicationController  
  before_action :authenticate_user! , except: [:attend]
  
  def index
    @courses = Course.includes([:lead,:user,:periods]).all
  end

  def show
    @course = Course.includes({periods: [:order_sheet,{teacher: :director},:period_tasks,:user,:course_address]}).find(params[:id])
    @tasks = CourseTask.where(course_id: @course.id)
    respond_to do |format|
      format.html { }
      format.json {}
      format.pdf {
        render pdf: "#{@course.name} (#{@course.lead.name})  - コース詳細",
               encoding: 'UTF-8',
               zoom: "0.9",
               layout: 'pdf.html',
               no_background: false,
               orientation: "Landscape",
               show_as_html: params[:debug].present?
      }
    end
  end

  def edit
    @course = Course.includes({periods: :order_sheet}).find(params[:id])
  end

  def calendar
    @courses = Course.includes(:lead)
    @periods = Period.includes(:course, :teacher).day_between(params[:start],params[:end])
    @new_task = CourseTask.new
    gon.google_api_key = Rails.application.secrets.google_api_key

    respond_to do |format|
      format.html {
      }
      format.json{
      }
      format.ics {
        @cal = Icalendar::Calendar.new
        @courses.each do |c|
          c.periods.each do |p|
            @cal.event do |e|
              e.dtstart     = Icalendar::Values::DateTime.new(p.start_date)
              e.dtend       = Icalendar::Values::DateTime.new(p.end_date)
              e.summary     = c.lead.name + "(" + p.teacher.name + ")"
              e.description = %Q{会社名:#{c.lead.name}\n講師名:#{p.teacher.name}}
            end
          end
        end
      }
    end
  end

  def attend
    period = Period.find(params[:id])
    period.update_attributes!(attend_date: DateTime.now)
    render :attend, :layout => "attend"
  end


  def list
    c = Course.all
    csvs = CSV.generate do |csv|
      csv << ["コマID","講師名","登壇日","開始時刻","終了時刻","コース名","企業名","メモ"]
      c.each do |c|
        c.periods.each do |period|
          csv << [period.id,period.teacher.name,period.day,period.start_date.to_s(:time),period.end_date.to_s(:time),c.name,c.lead.name, period.memo]
        end
      end
    end
    respond_to do |format|
      format.csv { send_csv csvs }
    end
  end


  def update
    @course = Course.find(params[:id])
    @course.assign_attributes(course_params)

    if @course.save
      flash[:notice] = 'コース情報を変更しました'
      redirect_to :action=> 'show', :id => params[:id]
    else
      flash[:alert] = '入力内容にエラーがあります'
      render "edit"
    end
  end
  
  def create
     @course = Course.new(course_params)     
     if @course.save
        flash[:notice] = @course.name + 'を追加しました。'
        redirect_to :controller => "courses", :action => "show", :id => @course.id
     else
       flash[:alert] = @course.errors.full_messages.join(',')
       render "new"
     end
  end
  def new
    @course = Course.new
  end

  def up_name
    @course = Course.find(params[:id])
    if @course.update_attributes(course_params)
       head :no_content
    else
       render json: @course.errors, status: :unprocessable_entity
    end
  end
  
  def up_bool
    @course = Course.find(params[:id])
    @type = params[:type]
    @bool = reverse_bool(@course.read_attribute(@type))
    if @course.update_attributes({@type => @bool})
    else
       render json: @course.errors, status: :unprocessable_entity
    end    
    
  end

  # DELETE /statuses/1
  # DELETE /statuses/1.json
  def destroy
    @course = Course.find(params[:id])
    @course.destroy
    flash[:notice] = 'コース情報を削除しました'
    redirect_to :action=> 'index'
  end


  private
  def course_params
    params.require(:course).permit(:name, :students,:user_id, :address, :tel, :station, :responsible,  :memo,  :lead_id,
        periods_attributes: [:id,:students, :theme, :order_avail, :course_address_id, :day, :start_time, :end_time, :break_start, :break_end, :teacher_id,:user_id, :memo,:price, :train_cost, :_destroy],
        course_addresses_attributes: [:id, :name, :address, :station, :responsible, :tel, :projector,:projector_detail, :board, :board_detail, :memo, :_destroy],
        course_tasks_attributes: [:id, :start,:end, :title,:memo, :_destroy]
        )
  end

end
