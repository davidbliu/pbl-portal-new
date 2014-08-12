class CommitmentsController < ApplicationController

  def index
    if not @current_member
      @commitments = []
    else
      @commitments = @current_member.commitments
    end
  end

  def update_commitments
    begin
      if not @current_member
        render :nothing => true, :status => 500, :content_type => 'text/html'
      end
      @current_member.commitments.destroy_all
      timeslots = params[:slots]
      for key in timeslots.keys
        for hour in timeslots[key]
          day = key.to_i
          start_hour = hour.to_i
          end_hour = hour.to_i + 1
          c = Commitment.new
          c.member_id = @current_member.id
          c.day = day
          c.start_hour = start_hour
          c.end_hour = end_hour
          c.save
        end
      end
      render :nothing => true, :status => 200, :content_type => 'text/html'
    rescue
      render :nothing => true, :status => 500, :content_type => 'text/html'
    end
    
  end
 
end
