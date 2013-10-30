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
    @neo = Neography::Rest.new
    puts "==RESULTS=="
    puts params.to_xml
    puts params[:treatment_3].nil?
    puts params[:months_1].nil?
    puts params[:treatments_1].nil?
    puts "==========="

    unless params[:months_1].nil? || params[:treatments_1].nil?
      query = "START user = node:Users('*:*') MATCH (h) <- [r1:reported] -> (user) - [r2:treated_with] -> (t) - [r3:treated_in] -> (m) WHERE t.name='" +
            params[:treatments_1] + "' AND m.name='" + params[:months_1] + "' RETURN h"
      @results = @neo.execute_query(query)["data"]
      puts "===================================="
      puts @results.first
      puts "===================================="
      puts @results
      puts "====================================="
    end

#    @testing = @neo.execute_query("START user = node:Users('*:*') MATCH (h) <- [r1:reported] -> (user) - [r2:treated_with] -> (t) - [r3:treated_in] -> (m) RETURN h, r1, user, r2, t, r3, m")["data"]
#    @testing = @neo.execute_query("START user = node:Users('*:*') MATCH (h) <- [r1:reported] -> (user) - [r2:treated_with] -> (t) - [r3:treated_in] -> (m) RETURN h")["data"]
    query = "START user = node:Users('*:*') MATCH (h) <- [r1:reported] -> (user) - [r2:treated_with] -> (t) - [r3:treated_in] -> (m) WHERE t.name='" +
            params[:treatments_1] + "' AND m.name='" + params[:months_1] + "' RETURN h"
    @testing = @neo.execute_query(query)["data"]
    
    @node_urls = Set.new
    @testing.each do |t|
      @node_urls.add(t.first["self"])
    end
    
    puts "==STILL RESULTS=="
    @nodes = []
    @node_urls.each do |n|
      @nodes.push(Neography::Node.load(n).value.to_f)
    end

    @hive_loss = @nodes.inject(0.0) { |sum, el| sum + el }.to_f / @nodes.size
    puts @hive_loss
    puts "================="


  end
end
