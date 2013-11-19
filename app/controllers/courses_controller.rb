class CoursesController < ApplicationController
  skip_before_filter :is_loggedin? , :only => [:search, :search_result]
  helper :all
  #get /courses
  def index
    @courses = current_user.courses
  end

  #GET /course/id
  def new
    @course = Course.new
  end

  #POST /course/id
  def create
    @course = Course.new(params[:course])
    @course.user_id = current_user.id
    if @course.save
      flash[:notice]="course created succefully."
      redirect_to course_control_courses_path
    else
      render :action => 'new'
    end
  end

  def get_course_form
    @course = Course.new(:course_type => params[:id])
    1.times { @course.documents.build }
    1.times { @course.videos.build }
    render :partial => 'course_form', :layout => false
  end
  
  #GET /course_control/id
  def course_control
    @course = params[:id] ? Course.find(params[:id]) : current_user.courses.first
  end


  def update_course_design
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice]="course control  form updated succefully"
      redirect_to course_control_courses_path(@course)
    end
  end

  #PUT /course_control/id
  def update_course_control
    @users = User.find(:all)
    @course = Course.find(params[:id])
    @course.amount = params[:amount_symbol] + "" + params[:amount] + "" + params[:package]
    if @course.update_attributes(params[:course])
      if @course.end_date >= @course.start_date
        if @course.status == 'published'
          @users.each do |user|
            if !user.every_new_course.blank? && user.every_new_course == 'yes'
              UserMailer.new_course_details(@course,user).deliver
            end
          end
        end
        flash[:notice]="course control  form updated succefully"
        redirect_to courses_path
      else
        flash[:error]="select the end date must be greater than the start date"
        render :action => 'course_control'
      end
    end
  end

  def show
    @course = Course.find(params[:id])
  end

  #EDIT /course/id
  def edit
    @course = Course.find(params[:id])
  end

  #POST /course/id
  def update
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice]="course design updated succefully"
      redirect_to edit_course_path(@course)
    else
      flash[:error]="course design form updation failed"
      render :action => 'edit'
    end
  end

  def course_view
    @course = params[:id] ? Course.find(params[:id]) : current_user.courses.first
  end

  def get_course_object
    @course = current_user.courses
  end

  def course_apply
    @courses = Course.search(params[:query])
  end

  def apply
    course = Course.find(params[:id])
    if !CoursesStudent.exists?(:course_id => course.id, :student_id => current_user.student.id)
      CoursesStudent.new(:course_id => course.id, :student_id => current_user.student.id, :status => 'pending').save
      flash[:notice] = 'Your information sent to mentor'
      redirect_to courses_path
    else
      flash[:error] = 'you are already applied for this course'
      redirect_to course_apply_courses_path
    end
  end

  def learner
    @courses_students = CoursesStudent.where("courses.user_id = #{current_user.id}").joins("LEFT JOIN courses ON courses.id = courses_students.course_id LEFT JOIN students ON students.id = courses_students.student_id LEFT JOIN users ON users.id = students.user_id").select("courses_students.id,courses_students.student_id, courses_students.created_at, courses_students.status, courses.name AS course_name, courses.strength AS course_strength,courses.id AS course_id, students.first_name AS student_first_name, users.account_id")
  end

  def course
    @courses = current_user.courses
  end

  def current
    #@course = params[:id] ? Course.find(params[:id]) : current_user.courses.first
    @courses = current_user.courses
    render :partial => "current", :layout => false
  end

  def topic
    @course = Course.find(params[:id])
    @courses_students =  @course.students.all
  end

  def student_course
    @courses_students = current_user.student.courses_students.all
  end

  def student_status
    @courses_students = current_user.student.courses_students.all
  end

  def status
    @courses = Course.all
  end

  def student_current_course
    @courses_students = current_user.student.courses_students.all
    render :partial => "student_current_course", :layout => false
    # render :update do |page|
    # page.replace_html 'current_student_course_div', (render :partial => "student_current_course", :layout => false)
    # end
  end

  def student_course_display
    @course = Course.find(params[:id])
  end

  def mentor_course
    @course = Course.find(params[:id])
    render :layout => 'other'
  end

  def student_list
    @course = Course.find(params[:id])
    @courses_students =  @course.students.where("courses_students.status = 'accepted'").all
    render :update do |page|
      page.replace_html 'course_div', (render :partial => "student_list", :layout => false)
    end
  end

  def accept
    @courses_student = CoursesStudent.find(params[:id])
    render :action => 'accept', :layout => false
    if @courses_student.status == 'pending'
      @courses_student.update_attribute( :status, 'accepted')
      flash[:notice] = 'Course is accepted by the mentor successfully'
    else
      flash[:error] = 'Course is already accepted '
    end
  end

  def reject
    @courses_student = CoursesStudent.find(params[:id])
    render :action => 'reject', :layout => false
    if @courses_student.status == 'pending'
      @courses_student.update_attribute( :status, 'rejected')
    else
      flash[:error] = 'This course is already accpted so you never delete this'
    end
  end
  
  def feedback
    @course = params[:id] ? Course.find(params[:id]) : current_user.courses.first
    if @course
      @course_feedbacks = @course.feedbacks
    else
    end
    render :layout => 'other'
  end

  def accept_message
    @courses_student = CoursesStudent.find(params[:id])
    if @courses_student.student.user.course_accept_reject == 'yes'
      @accept_message = Message.new(params[:accept_message].merge({:user_id => current_user.id, :receiver_id => @courses_student.student.user.id })).save
    end
    render :update do |page|
      page.redirect_to learner_courses_path
    end
    flash[:notice]= "Your's Message sucessfully sent."
  end

  def reject_message
    @courses_student = CoursesStudent.find(params[:id])
    if @courses_student.student.user.course_accept_reject == 'yes'
      @reject_message = Message.new(params[:reject_message].merge({:user_id => current_user.id, :receiver_id => @courses_student.student.user.id })).save
    end
    render :update do |page|
      page.redirect_to learner_courses_path
    end
    flash[:notice]= "Your's Message sucessfully sent."
  end

  def search
    @courses = Course.search "*#{params[:query]}*"
    if !current_user
      render :action => "search_result",:layout => "application"
    else
      render :action => "index"
    end
  end

  def search_result
    @courses = Course.all
  end
end
