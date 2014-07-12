require 'json'
class TablingSlotMembersController < ApplicationController


  def create
    p 'create'
    # if params[:member_id]
    #   member = Member.find(params[:member_id])
    #   tabling_slot = TablingSlot.find(params[:tabling_slot_member][:tabling_slot_id])

    #   member.tabling_slots << tabling_slot
    # end

    # respond_to do |format|
    #   format.html { redirect_to tabling_slot }
    #   format.js
    # end

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

    # respond_to do |format|
    #   format.html { render 'destroy.js.erb' }
    #   format.js
    # end
    render :nothing => true, :status => 200, :content_type => 'text/html'
  end

 
end
