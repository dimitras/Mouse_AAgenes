#!/usr/bin/env ruby

# create mascot database for mouse cox pathway AAgenes

$LOAD_PATH << './lib'
require 'rubygems'
require 'fastercsv'
require 'fasta_parser'

all_outfile = 'results/Mouse_AAgenes_uniprot_db.fasta'
proteome_db_fasta_file = 'data/MOUSE2013.fasta'
names_list_file = 'data/Mouse_AAgenes_uncurated_updated.csv'

# read proteome fasta and create a fasta dictionary
fasta_dictionary = Hash.new { |h,k| h[k] = [] }
proteome_db_fap = FastaParser.open(proteome_db_fasta_file)
proteome_db_fap.each do |fasta_entry|
  prot_accno = fasta_entry.accno # protein accno
  if prot_accno.include?('-')
    fasta_entry.desc =~ /(.+)_MOUSE.+GN=(.+).*/
  else
    fasta_entry.desc =~ /(.+)_MOUSE.+GN=(.+)\sPE.+/
  end
  genename = $2 # genename
  fasta_dictionary[genename] << [prot_accno, fasta_entry.desc, fasta_entry.seq, fasta_entry.tag]
end

# read the list with genenames and create a hash with our genes that were found in the fasta dictionary
genes_to_common_names = Hash.new { |h,k| h[k] = [] }
FasterCSV.foreach(names_list_file) do |row|
  genename = row[0]
  genes_to_common_names[genename] = fasta_dictionary[genename]
end

# 
fasta = File.open(all_outfile,'w') 
genes_to_common_names.each do |genename, entries|
  for i in 0..entries.length-1
    seq_to_fasta = ""
    fasta.puts ">#{genes_to_common_names[genename][i][3]}|#{genes_to_common_names[genename][i][0]}|#{genes_to_common_names[genename][i][1]}"
    # to fasta format
    seq = genes_to_common_names[genename][i][2].to_s
    (0..seq.length-2).each do |i|
    seq_to_fasta = seq_to_fasta + seq[i..i]
      if ((i+1) % 60 == 0)
        seq_to_fasta = seq_to_fasta + "\n"
      end
    end
    seq_to_fasta = seq_to_fasta + seq[seq.length-1..seq.length-1]
    fasta.puts seq_to_fasta
  end
end

