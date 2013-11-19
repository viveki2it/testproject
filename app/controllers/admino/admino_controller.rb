class Admino::AdminoController < ApplicationController
  skip_before_filter :is_loggedin?
  layout 'admin'
  before_filter :authenticate
  def index
  end
end
