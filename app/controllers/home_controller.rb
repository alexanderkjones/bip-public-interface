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
    
    
    @testing = @neo.execute_query("START n=node* MATCH (Losses) <- [:REPORTED] - (Users) - [:TREATED_WITH] - (Treatments) - [:TREATED_IN] -> Months WHERE Months == April && Treatment == Apilife Var || Months == May && Treatments == ApiGuard RETURN AVG(Losses)")

    puts "==TESTING=="
    puts @testing
    puts "==========="    
  end
  
  def results
    puts "==RESULTS=="
    puts params.to_xml
    puts "========"
  end
end
