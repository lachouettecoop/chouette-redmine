class CalendarController < ApplicationController
  unloadable

  def index
    #DO NOTHING
  end

  def form_holiday(holiday)
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'user') + '</td>'
    ret_var << '<td>' + holiday.user.login + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'start') + '</td>'
    ret_var << '<td>' + holiday.start.to_date.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'end') + '</td>'
    ret_var << '<td>' + holiday.end.to_date.to_s + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end
  def form_issue(issue)
    ticket_time = TicketTime.where({:issue_id => issue.id}).first rescue nil
    tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
    tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
    ret_var = '<table>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'project') + '</td>'
    ret_var << '<td>' + issue.project.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'status') + '</td>'
    ret_var << '<td>' + issue.status.name + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'user') + '</td>'
    ret_var << '<td>' + issue.assigned_to.login + '</td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'start') + '</td>'
    ret_var << '<td>' + issue.start_date.to_date.to_s + ' ' + tbegin + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '<tr>'
    ret_var << '<td>' + (translate 'end') + '</td>'
    ret_var << '<td>' + issue.due_date.to_date.to_s + ' ' + tend + ' </td>' rescue '<td></td>'
    ret_var << '</tr>'
    ret_var << '</table>'
    return ret_var
  end
  def get_events
    fbegin = params[:start].to_date rescue nil
    fend = params[:end].to_date rescue nil
    fuser = params[:user].to_s == 'true'
    fbegin = (Date.today - 1.month) if(fbegin.blank?)
    fend = (Date.today + 1.month) if(fend.blank?)
    holidays = Holiday.where(['holidays.start >= ? AND holidays.end <= ?' + (fuser.blank? ? '' : ' AND holidays.user_id = ' + User.current.id.to_s),fbegin.to_s, fend.to_s]) rescue []
    issues = Issue.where(['issues.start_date >= ? AND issues.due_date <= ?' + (fuser.blank? ? '' : ' AND issues.assigned_to_id = ' + User.current.id.to_s),fbegin.to_s, fend.to_s]) rescue []
    @events = []
    def_holiday = '#' + Setting.plugin_mega_calendar['default_holiday_color']
    def_color = '#' + Setting.plugin_mega_calendar['default_event_color']
    @events = @events + holidays.collect {|h| {:id => h.id.to_s, :controller_name => 'holiday', :title => (h.user.blank? ? '' : h.user.login + ' - ') + (translate 'holiday'), :start => h.start.to_date.to_s, :end => h.end.to_date.to_s, :allDay => true, :color => def_holiday, :url => '/holidays/show?id=' + h.id.to_s, :className => 'calendar_event', :description => form_holiday(h) }}
    issues.each do |i|
      ticket_time = TicketTime.where({:issue_id => i.id}).first rescue nil
      tbegin = ticket_time.time_begin.strftime(" %H:%M") rescue ''
      tend = ticket_time.time_end.strftime(" %H:%M") rescue ''
      css_classes = ['calendar_event']
      if !i.status.blank? && i.status.is_closed == true
        css_classes << 'calendar_event_closed'
      end
      color = '#' + UserColor.where({:user_id => i.assigned_to_id}).first.color_code rescue def_color
      @events << {:id => i.id.to_s, :controller_name => 'issue', :title => i.id.to_s + ' - ' + i.subject, :start => i.start_date.to_date.to_s + tbegin, :end => i.due_date.to_date.to_s + tend, :color => color, :url => '/issues/' + i.id.to_s, :className => css_classes, :description => form_issue(i) }
    end
    render(:text => @events.to_json.html_safe)
  end
  def change_holiday
    h = Holiday.find(params[:id])
    if !params[:event_end].blank?
      h.update_attributes({:start => params[:event_begin].to_date.to_s, :end => params[:event_end].to_date.to_s}) rescue nil
    else
      h.update_attributes({:start => params[:event_begin].to_date.to_s, :end => params[:event_begin].to_date.to_s}) rescue nil
    end
    render(:text => "")
  end
  def change_issue
    i = Issue.find(params[:id])
    if params[:event_end].blank?
      event_end = params[:event_begin]
    else
      event_end = params[:event_end]
    end
    i.update_attributes({:start_date => params[:event_begin].to_date.to_s, :due_date => event_end.to_date.to_s}) rescue nil
    if params[:allDay] != 'true'
      tt = TicketTime.where(:issue_id => params[:id]).first 
      if tt.blank?
        tt = TicketTime.new(:issue_id => params[:id])
      end
      tt.time_begin = params[:event_begin].to_datetime.to_s
      if !params[:event_end].blank?
        tt.time_end = params[:event_end].to_datetime.to_s rescue nil
      else
        i.update_attributes({:due_date => (params[:event_begin].to_datetime + 2.hours).to_datetime.to_s})
        tt.time_end = (params[:event_begin].to_datetime + 2.hours).to_datetime.to_s
      end
      tt.save
    else
      tt = TicketTime.where(:issue_id => params[:id]).first rescue nil
      if !tt.blank?
        tt.destroy()
      end
    end
    render(:text => "")
  end
end
