class Admino::ReportsController < ApplicationController
  skip_before_filter :is_loggedin?
  before_filter :authenticate
  layout 'admin'
  def index
  end

  def search
    @users = User.search(params[:query])
  end
end
