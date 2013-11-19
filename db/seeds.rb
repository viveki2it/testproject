# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
User.create({:email => 'admin@example.com', :password => '1234', :password_confirmation => '1234', :user_type => 'admin', :account_id => 'AAAV57', :login => 'root', :role => 'admin', :status => 'active'})
