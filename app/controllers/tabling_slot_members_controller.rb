class TablingSlotMembersController < ApplicationController


  def create
    p 'create'
     render :nothing => true, :status => 404, :content_type => 'text/html'
  end

  def update
    p 'update'
    tsm = TablingSlotMember.find(params[:id])
    tsm.tabling_slot = TablingSlot.find(params[:tabling_slot_id])
    tsm.save!
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

  def destroy
    p 'destroy'
    tsm = TablingSlotMember.find(params[:id]).destroy
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

 
end
