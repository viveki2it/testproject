class StudentsController < ApplicationController
  before_filter :get_student_object, :only => [:new, :other_message, :education, :update_education, :others, :update_others, :edit, :update, :destroy, :education_profile, :update_education_profile, :get_education_form, :get_education_profile_form]
  before_filter :is_student_exists?, :only => [:edit, :update, :destroy, :education, :update_education, :others, :update_others]
  layout :get_layout, :except => [:new, :create, :education, :get_education_form, :update_education, :others, :update_others, :edit, :update ]
  skip_before_filter :is_loggedin?, :only => [:student_view,:show]

  #GET /students/new
  def new
    unless @student
      @student = Student.new
      render :layout => "application"
    else
      redirect_to edit_student_path(@student)
      return
    end
  end

  #POST /students
  def create
    @student = Student.new(params[:student])
    @student.user_id = current_user.id

    if @student.save
      flash[:notice]= "student personal details created successfully"
      redirect_to education_student_path(@student)
      return
    else
      flash[:error]= "student personal details creation failed"
      render :action => :new
    end
  end


  #GET /students/1/education
  def education
    render :layout => 'application'
  end

  def get_education_form
    render :partial => "education_form", :locals => {:education_type => params[:education_type]}
  end

  #PUT /students/:id/update_education
  def update_education
    if @student.update_attributes(params[:student])
      flash[:notice]="Student education form updated succefully"
      render :update do |page|
        page.redirect_to others_student_path
      end
    else
      flash[:error]="Student education form updation failed"
      render :update do |page|
        page.replace_html "student_education_form", (render :partial => "education_form", :locals => {:education_type => params[:student][:education_type]})
      end
    end
  end
  def show
    @student = Student.find(params[:id])
    render :layout => 'other'
  end

  #GET /students/1/others
  def others
    @user = current_user.id
    @invite = Invite.new
    render :layout => 'application'
  end

  #POST
  #Send invitation users.
  def invite
    @invite = Invite.new(params[:invite])
    @invite.user_id = current_user.id
    render :update do |page|
      if @invite.save
        #UserMailer.send_invitation(@invite).deliver
        if params[:action] == "invite_friends"
          page.alert('Invitation sent successfully')
        else
          page.alert('Invitation sent successfully')
          page.redirect_to home_index_path
        end
      else
        params[:emails].present? ? page.alert('Please Enter Correct Email') : page.alert('Please Enter Atleast One Email')
      end
    end
  end

  #GET for invite friends
  def invite_friends
    @invite = Invite.new
  end
  
  #PUT /students/:id/update_others
  def update_others
    if @student.update_attributes(params[:student])
      flash[:notice]="Student others form updated successfully"
      
      redirect_to home_index_path
    end
 
    
  end
  #GET students/1/edit
  def edit
    render :layout => 'application'
  end

  #PUT /students/1
  def update
    if @student.update_attributes(params[:student])
      flash[:notice]="Student personal form updated succefully"
      redirect_to education_student_path(@student)
    else
      flash[:error]="Student personal form updation failed"
      render :action => 'edit'
    end
  end


  #DELETE /students/1
  def destroy
    @student.destroy
    redirect_to students_path
  end

  def get_student_object
    @student = current_user.student
  end

  def is_student_exists?
    redirect_to new_student_path unless @student
  end

  def basic_info
  end

  def update_basic_info
    if current_user.student.update_attributes(params[:student])
      flash[:notice]="Student personal details updated succefully"
    else
      flash[:error] = "Student personal details updated failed"
    end
    redirect_to basic_info_students_path(@student)
  end

  def get_education_profile_form
    render :partial => "education_profile_form", :locals => {:education_type => params[:education_type]}
  end

  def education_profile
  end

  def update_education_profile
    if @student.update_attributes(params[:student])
      flash[:notice]="Student education form updated succefully"
      render :update do |page|
        page.redirect_to education_profile_student_path
      end
    else
      flash[:error]="Student education form updation failed"
      render :update do |page|
        page.replace_html "education_profile_form", (render :partial => "education_profile_form", :locals => {:education_type => params[:student][:education_type]})
      end
    end
  end

  def work
  end
  def update_work
    if current_user.student.update_attributes(params[:student])
      flash[:notice] = "Student Work details updated succefully"
    else
      flash[:error] = "Student Work details updation failed"
    end
    redirect_to work_students_path
  end

  def interest
  end

  def other_message
    @student = Student.find(params[:id])
    render :partial => 'student_message', :layout => false
  end

  def student_message
    @student = Student.find(params[:id])
    @student_message = Message.new(params[:student_message].merge({:user_id => current_user.id, :receiver_id => @student.user.id})).save
    render :update do |page|
      page.replace_html "message_notice", "Your's message sucessfully sent."
    end
  end

  def update_interest
    if current_user.student.update_attributes(params[:student])
      flash[:notice] = "Student interest details updated succefully"
    else
      flash[:error] = "Student interest details updation failed"
    end
    redirect_to interest_students_path
  end

  def student_view
    @student = Student.find(params[:id])
    @student_free_course = CoursesStudent.where("students.id = '#{@student.id}' and courses.course_fee = 'free'").joins("LEFT JOIN courses ON courses.id = courses_students.course_id LEFT JOIN students ON students.id = courses_students.student_id")
    @student_paid_course = CoursesStudent.where("students.id = '#{@student.id}' and courses.course_fee = 'paid'").joins("LEFT JOIN courses ON courses.id = courses_students.course_id LEFT JOIN students ON students.id = courses_students.student_id")
    @student_courses = CoursesStudent.where("students.id = '#{@student.id}'").joins("LEFT JOIN courses ON courses.id = courses_students.course_id LEFT JOIN students ON students.id = courses_students.student_id").select("courses.name AS course_name, courses.start_date AS start_date, courses.end_date AS end_date")
    render :update do |page|
      page.replace_html 'show_div', (render :partial => 'student_view', :layout => false)
    end
  end
  
end
