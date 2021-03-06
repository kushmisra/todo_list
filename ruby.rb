require 'sinatra'
require 'data_mapper'
set :port,"3233"

set :sessions,true

DataMapper.setup(:default,"sqlite:///#{Dir.pwd}/todolist.db")
set :public_folder,File.dirname(__FILE__)+'/static'

class Task
	include DataMapper::Resource
	property :id , Serial
	property :t_name , String
	property :t_priority , Boolean
	property :t_importance , Boolean
	property :t_done , Boolean
	property :t_edit , Boolean
 	property :t_id , Integer
end

class User
	include DataMapper::Resource
	property :id, Serial
	property :email, String
	property :password, String
end

DataMapper.finalize
Task.auto_upgrade!
User.auto_upgrade!

urgent=false
important=false
calledonlydone=false

get '/'  do
	
		task_list=nil
		if session[:user_id] 
			
			if(!calledonlydone)
				task_list=Task.all(:t_id=>session[:user_id])
			else
				task_list=Task.all({:t_done=>true,:t_id=>session[:user_id]})
				calledonlydone=false
			end
		else
			redirect '/signin'
			return
		end
			
		imp=""
		ur=""
		if(important)
			imp="important"
		end
		if(urgent)
			ur="urgent"
		end

		current=User.get(session[:user_id]).email

		erb :eerrbb	,locals: {:task_list=>task_list,:important=>imp,:urgent=>ur,:current=>current}
end


post '/enter_task' do

	Task.create(:t_name=>params[:task_name],:t_priority=>urgent,:t_importance=>important,:t_done=>false,:t_edit=>false,:t_id=>session[:user_id])
	
	important=false
	urgent=false
	redirect '/'

end

post '/logout' do

	session[:user_id]=nil
	redirect '/'

end

post '/alldone' do
	calledonlydone=true
	redirect '/'
end

post '/alltasks' do
	calledonlydone=false
	redirect '/'
end

post '/important' do

	important=!important
	redirect '/'
end

post '/urgent' do

	urgent=!urgent
	redirect '/'

end	

post '/toggle_important' do

	id=params[:id].to_i
	testing=id
	task=Task.get(id)
	task.t_importance=!task.t_importance
	task.save

	redirect '/'
	
end

post '/toggle_urgent' do
	
	id=params[:id].to_i

	task=Task.get(id)

	task.t_priority=!task.t_priority
	task.save
	#Task.auto_upgrade!
	redirect '/'
end	

post '/task_remove' do
	
	id=params[:id].to_i

	task=Task.get(id)

	task.destroy
	#Task.auto_upgrade!
	redirect '/'

end	

post '/task_done' do
	
	id=params[:id].to_i

	task=Task.get(id)

	task.t_done=!task.t_done

	#Task.auto_upgrade!
	task.save
	redirect '/'
end	

post '/register' do

	email=params[:email]
	password=params[:password]

	user=User.all(:email => email).first

	if user
		redirect '/signup'
	else
		user=User.new
		user.email=email
		user.password=password
		user.save
		session[:user_id]=user.id
		puts "kkkkkkkkkkkk",user.id,"kkkkkkkkkkkkkk",session[:user_id],"kkkkkkkkkkkkkkkkkkk"
		redirect '/'
	end
end

get '/signup' do

 erb :signup

end

get '/signin' do

	erb :login

end


post '/validate' do

	email=params[:email]
	password=params[:password]
	user=User.all(:email=>email).first
	if user
		session[:user_id]=user.id
		redirect '/'
		return
	end

	redirect '/signin'

end




