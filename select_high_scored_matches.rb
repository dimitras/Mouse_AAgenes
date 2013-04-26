#!/usr/bin/env ruby

# USAGE: 
# first run oneliner to remove carriage returns (\r\n) from mgf file
# perl -p -e 's/\r\n/\n/g' < data/mascot_runs/merged_H_F001694.mgf > data/mascot_runs/merged_H_F001694_2.mgf
# delete the last line of the file
# ghead -n -1 data/mascot_runs/merged_H_F001694_2.mgf > data/mascot_runs/merged_H_F001694_3.mgf
# ruby select_high_scored_matches.rb data/mascot_runs/F001694.csv data/mascot_runs/merged_H_F001694_3.mgf data/mascot_runs/merged_H_F001694_reduced.mgf
# SELECTED 2317/163303

# perl -p -e 's/\r\n/\n/g' < data/mascot_runs/merged_L_F001695.mgf > data/mascot_runs/merged_L_F001695_2.mgf
# ghead -n -1 data/mascot_runs/merged_L_F001695_2.mgf > data/mascot_runs/merged_L_F001695_3.mgf
# ruby select_high_scored_matches.rb data/mascot_runs/F001695.csv data/mascot_runs/merged_L_F001695_3.mgf data/mascot_runs/merged_L_F001695_reduced.mgf
# SELECTED 3191/158915

# select high scored matches from the csv file, so as to create a reduced mgf file to rerun a mascot search

require 'rubygems'
require 'fastercsv'
require 'mascot/mgf'

# arguments
csv_file = ARGV[0]
mgf_file = ARGV[1]
mgf_reduced_ofile = ARGV[2]

# filter the queries by score (ex 20) and identify the titles for these queries in the csv file
fieldnames = []
selected_queries = {}
FasterCSV.foreach(csv_file) do |row|
	if fieldnames.empty? && row[0] == "prot_hit_num"
		fieldnames = row
	elsif !fieldnames.empty?
        query = row[9].to_i
        pep_score = row[19].to_f
        title = row[26].to_s
        if pep_score >= 20.0
        	selected_queries[query] = title
        end
    end
end

puts "#Selected CSV length: #{selected_queries.length}" 

# identify these titles (ex Heart_02212013_H.370.370.2) in the merged mgf file
mgf = Mascot::MGF.open(mgf_file)
mgf_reduced = File.open(mgf_reduced_ofile,'w') 

puts "#MGF length: #{mgf.query_count}"

mgf.each_query do |query_object|
	if selected_queries.has_value?(query_object.title)
		mgf_reduced.puts query_object
	end
end
mgf_reduced.close

