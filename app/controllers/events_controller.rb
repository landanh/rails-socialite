class EventsController < ApplicationController

  before_action :only_host_action, only: [:add]

  def index
    @event_time = if params[:event_time].blank? || ['upcoming', 'past'].index(params[:event_time]).nil?
      'upcoming'
    else
      params[:event_time]
    end
    @events = if @account_type == 'host'
      if @event_time == 'upcoming'
        Event.get_upcoming_events_by_host(@current_host.id)
      else
        Event.get_past_events_by_host(@current_host.id)
      end
      else
      if @event_time == 'upcoming'
        Event.get_events_for_user(1)
      else
        Event.get_past_public_events
      end
    end
  end

  def add
    if request.post?
      @event = Event.new(event_params.merge(host_id: @current_host.id))
      if @event.valid? && @event.save
        redirect_to events_index_path
      else
        flash[:error] = @event.errors.full_messages.map { |v| v }.join('<br/>')
        redirect_to events_add_path
      end
    else
      @event = Event.new
    end
  end

  def invite
    if request.post?
      @invite = Invite.new(event_id: params[:event_id], user_id: params[:user_id])
      @invite.save
      redirect_to events_invite_path(event_id: params[:event_id])
    else
      @event = Event.find_by(id: params[:event_id])
      @users = if params[:search]
                 User.search(params[:search])
               else
                 User.all
               end
    end
  end

  def rsvp
    if request.post?
      additional_guests = params[:invite][:additional_guests]
      if params[:rsvp] == 'false'
        additional_guests = 0
      end
      @event = Event.find_by(id: params[:event_id])
      @invite = Invite.find_by(event_id: params[:event_id], user_id: params[:user_id])
      if @invite
        if @event.event_type == 'public' && params[:rsvp] == 'false'
          @invite.destroy
        else
          @invite.update(rsvp: params[:rsvp], additional_guests: additional_guests)
        end
      else
        if params[:rsvp] == 'true'
          @invite = Invite.new(event_id: params[:event_id], user_id: params[:user_id], rsvp: params[:rsvp], additional_guests: additional_guests)
          @invite.save
        end
      end
      redirect_to events_index_path
    else
      @event = Event.find_by(id: params[:event_id])
      @invite = Invite.find_by(event_id: params[:event_id], user_id: @current_user.id)
      if !@invite
        @invite = Invite.new
      end
    end
  end

  def agenda
    @events = Event.get_agenda_for_user(@current_user.id)
  end

  def guest_list
    @guests = User.get_guest_list(params[:event_id])
    respond_to do |format|
      format.html
      format.csv { send_data @guests.to_csv }
    end
  end

  private

  def event_params
    params.require(:event).permit(:event_name, :description, :capacity, :event_start, :event_end, :rsvp_start, :rsvp_end, :event_type, :venue_addr1, :venue_addr2, :venue_city, :venue_state, :venue_zip)
  end

  def rsvp_params
    params.require(:invite).permit(:rsvp, :additional_guests)
  end

end