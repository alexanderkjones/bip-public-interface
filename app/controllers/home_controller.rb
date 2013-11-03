class HomeController < ApplicationController
  def index
    @neo = Neography::Rest.new
    @the_months = @neo.execute_query("START n=node:Months('*:*') RETURN n")["data"]
    @months = []
    @the_months.each do |m|
      @months.push(Neography::Node.load(m.first["self"]))
    end

    @the_products = @neo.execute_query("START n=node:Products('*:*') RETURN n")["data"]    
    @products = []
    @the_products.each do |t|
      @products.push(Neography::Node.load(t.first["self"]))
    end

#    @testing = @neo.execute_query(query)
    
#    puts @testing
    @the_users = @neo.execute_query("START n=node:Users('*:*') RETURN n")["data"]
    
    @users = []
    @the_users.each do |u|
      @users.push(Neography::Node.load(u.first["self"]))
    end
    
    puts @users
  end
  
  def results
    @neo = Neography::Rest.new
    puts "==RESULTS=="
    puts params.to_xml
    puts "==================================="

#    query = "START root=node(1) return root"
    
    query = "START user=node:Users('*:*') MATCH (hiveloss) <- [r1:reported] -> (user) - " +
    "[r2:used] -> (schedule) - [r3:applied] -> (treatment) - [r4:date_applied] -> (month) " +
    "WHERE treatment.name='Apivar' " +
    "RETURN hiveloss"
    
    @loss = @neo.execute_query(query)
    
    puts @loss

    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end
  
  def results_old
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
