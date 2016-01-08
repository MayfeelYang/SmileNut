class ActivitesController < ApplicationController 
  
  def all_events
    
		@activities = Activity.all()
		@activities.each do |activity|
			puts activity.start_date.strftime("%Y-%m-%d %H:%M")
			puts activity.to_s
		end
		#@activities = Activity.all()
		@candidate = []
		if(params[:tag])
			@activities.each do |activity|
				@get_tag = params[:tag]
				puts @get_tag
				@tags = activity.tag.split(",")
				@tags.each do |tag|
					if(tag == @get_tag)
						@candidate.push(activity.id)
					end
				end
			end
			puts @candidate
			@activities = Activity.find @candidate

		end
		
		if (params[:edit] == 1)
			session[:edit] = true
		end
		
	end

	def edit
		puts params[:data]
		puts "-----------------",params.inspect
		@activity = Activity.find(params[:id])
		
	end
	
	def delete
		id = params[:id]
		@activity = Activity.find(id)
		@activity.destroy
		redirect_to activites_all_events_path
	end	
	
	
	def update
		params.permit!
		puts params[:activity]
		id = params[:id].to_i
		puts "----------id",id
		update_activity = Activity.find(id)
		update_activity.update_attributes(params[:activity])
		redirect_to {controller:"activites",action:"show",id: id}
		
	end

	#------其他def-------
	def add
	
		@activity = Activity.find params[:acid]
		if (params[:type] == "recommend")
			@activity.update_attributes(:recommend => (@activity.recommend + 1))
		else
			@activity.update_attributes(:want_join => (@activity.want_join + 1))
		end
		
		redirect_to :back
	end
  
  def launch
  #  @activity = Activity.launch(params[:activity])
  end
  
  def new
    @activity = Activity.new
  end
  
  def create
    @launch_activity = params[:activity]
    activity_param = {}
    activity_param[:name] = @launch_activity["name"]
    activity_param[:user_id] = (User.where(:name => session[:user_name])).ids[0]
    activity_param[:content] = @launch_activity["content"]
    activity_param[:tag] = @launch_activity["tag"]
    activity_param[:detail_addr] = @launch_activity["detail_addr"]
    
    
    activity_param[:start_date] = @launch_activity["start_date"]
    activity_param[:end_date] = @launch_activity["end_date"]
    
    activity_param[:recommend]=0
    activity_param[:province]="北京市"
    activity_param[:district]="怀柔区"
    activity_param[:city]="北京市"
    
    
    activity_added = Activity.new(activity_param)
    if activity_added.save
      logger.debug {"success"}
      user = User.find(activity_param[:user_id])
      puts user
      activity_ids = []
      if user.Sponsor_Activity
      	activity_ids = JSON.parse(user.Sponsor_Activity)
      end
      activity_ids.push(user.id)
      info = user.update!(Sponsor_Activity: activity_ids.to_json)
      redirect_to  "/activites/all-events"
    else
      puts "-------------------------"
      puts params["activity"]["start_date"]
      puts params["activity"]["end_date"]
      puts "activity save info"
      puts activity_added.inspect
      render plain: activity_added.errors.full_messages.inspect
      
    end
 #   render plain: activity_added.inspect
    
  end
  
  def show
		id = params[:id]
		@activity = Activity.find(id)
		if (session[:user_name])
			@activity_owner_id = User.find_by(Name: session[:user_name]).id
			puts "************************************************"
			puts @ctivity_owner_id 
		end
	end	

end
