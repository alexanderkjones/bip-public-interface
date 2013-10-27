class HomeController < ApplicationController
  def index
    @neo = Neography::Rest.new
    @the_months = @neo.execute_query("START n=node:Months('*:*') RETURN n")["data"]
    @months = []
    @the_months.each do |m|
      @months.push(Neography::Node.load(m.first["self"]))
    end

    @the_treatments = @neo.execute_query("START n=node:Treatments('*:*') RETURN n")["data"]    
    @treatments = []
    @the_treatments.each do |t|
      @treatments.push(Neography::Node.load(t.first["self"]))
    end
  end
  
  def results
    puts "==RESULTS=="
    puts params.to_xml
    puts "========"
  end
end
