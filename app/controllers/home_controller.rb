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
    
    query = "START apivar=node(10), april=node:Months('name:April'), june=node(14), august=node(15) " +
            "MATCH (schedule) - [:APPLIED] -> (t1) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t2) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t3) - [:PRODUCT_USED] -> (apivar), " +
            "(t1) - [:DATE_APPLIED] -> (april), " +
            "(t2) - [:DATE_APPLIED] -> (june), " +
            "(t3) - [:DATE_APPLIED] -> (august) " +
            "WHERE (schedule.num_products=1) AND (schedule.num_treatments=3) " +
            "WITH DISTINCT schedule " +
            "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
            "RETURN user as user, hiveloss as hive_loss"
    
#    @hiveloss = @neo.execute_query(query)

    # @users = []
    # @the_users.each do |u|
      # @users.push(Neography::Node.load(u.first["self"]))
    # end
    
#    puts @hiveloss
  end
  
  def results
    @neo = Neography::Rest.new
    puts "==RESULTS=="
    puts params.to_xml
    puts params[:plans][0].nil?
    puts "==================================="

    
    
    #@loss = @neo.execute_query(query)
    
    #puts @loss

    respond_to do |format|
      format.json { render json: {}, status: :ok }
    end
  end
  
  def query
    @neo = Neography::Rest.new
    
    query_1 = "START apivar=node(10), april=node:Months('name:April'), june=node(14), august=node(15) " +
            "MATCH (schedule) - [:APPLIED] -> (t1) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t2) - [:PRODUCT_USED] -> (apivar), " +
            "(schedule) - [:APPLIED] -> (t3) - [:PRODUCT_USED] -> (apivar), " +
            "(t1) - [:DATE_APPLIED] -> (april), " +
            "(t2) - [:DATE_APPLIED] -> (june), " +
            "(t3) - [:DATE_APPLIED] -> (august) " +
            "WHERE (schedule.num_products=1) AND (schedule.num_treatments=3) " +
            "WITH DISTINCT schedule " +
            "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
            "RETURN user as user"
            
    @query1 = @neo.execute_query(query_1)["data"]    
    @query1_results = []
    
    for i in 0..@query1.length-1
      @query1_results.push(@query1[i].first["data"]["name"]) unless @query1_results.include?(@query1[i].first["data"]["name"])
    end

    query_2 = "START apivar=node(10)" +
              "MATCH (schedule) - [:APPLIED] -> (t) - [:PRODUCT_USED] -> (apivar)" +
              "WHERE (schedule.num_products=1)" +
              "WITH DISTINCT schedule " +
              "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
              "RETURN schedule as schedule, user as user, hiveloss as hive_loss"
              
    @query2 = @neo.execute_query(query_2)["data"]
    @query2_results = []
    
    for i in 0..@query2.length-1
      @query2_results.push(@query2[i].first["data"]) unless @query2_results.include?(@query2[i].first["data"])
    end
    
    query_3 = "START apivar=node(10), april=node(13), june=node(14), august=node(15) " +
              "MATCH (schedule) - [:APPLIED] -> (t1) - [:DATE_APPLIED] -> (april), " +
              "(schedule) - [:APPLIED] -> (t2) - [:DATE_APPLIED] -> (june), " +
              "(schedule) - [:APPLIED] -> (t3) - [:DATE_APPLIED] -> (august) " +
              "WHERE (schedule.num_treatments=3) " +
              "WITH DISTINCT schedule " +
              "MATCH (hiveloss) <- [:REPORTED] - (user) - [:USED] -> (schedule) " +
              "RETURN schedule as schedule, user as user, hiveloss as hive_loss"
              
    @query3 = @neo.execute_query(query_3)["data"]
    @query3_results = []
    
    for i in 0..@query3.length-1
      @query3_results.push(@query3[i].first["data"]) unless @query3_results.include?(@query3[i].first["data"])
    end
    
    puts @query3_results
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
