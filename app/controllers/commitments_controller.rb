class CommitmentsController < ApplicationController

  def index
    if not @current_member
      @commitments = []
    else
      @commitments = @current_member.commitments
    end

    if current_member and current_member.admin?
        @pbl_commitments = Hash.new
          Member.current_members.each do |member|
            @pbl_commitments[member.id] = Array.new
            for c in member.commitments
              if c.day and c.start_hour and c.end_hour
                @pbl_commitments[member.id] << "#"+c.day.to_s+" #"+c.start_hour.to_s
              end
            end
          end
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
