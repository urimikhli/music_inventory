#the inventory
#
require 'csv'
require 'json'
require 'byebug'

class Inventory
  attr_accessor :records

  INVENTORYSTORE = 'db/inventory.json'

  def initialize
    @records = load_file(INVENTORYSTORE.to_s)
  end

  def load_new_inventory(filename)
    @records = merge_records_sets(records,load_file(filename))
    persist
  end

  def search_inventory(search_field, query_field)
    output records_search(search_field, query_field)
  end

  def purchase(format_uid)
    album = format_search(format_uid)
    return puts "The uid: #{format_uid} does not exist." if album.nil?

    purchase_format = album["formats"].select{|y| format_uid.downcase == y["uid"].downcase }.last

    return puts "There is no album #{format_uid} available in the inventory" if purchase_format.nil?

    purchase_format["quantity"] -= 1

    puts "Removed 1 #{purchase_format['format']} of #{album["title"]} by #{album["artist"]} from the inventory"

    cleanup_inventory album #remove any records with quantity 0

    persist

  end

  private

  def cleanup_inventory(album)
    album["formats"].delete_if {|x| x['quantity'] == 0}
    @records.delete_if {|x| x["formats"].empty?}
  end

  def format_search(format_uid)
    @records.select{|x| /#{x["uid"].downcase}/.match(format_uid.downcase) }.last
  end

  def records_search(search_field, query_field)
    @records.select{|x| /#{query_field.downcase}/.match(x[search_field].downcase) }.sort_by { |hsh| hsh[search_field] }
  end

  def persist
    #the concept is that the file will be overwritten everytime
    File.open(INVENTORYSTORE.to_s,"w"){ |f| f << JSON.pretty_generate(@records)}
    @records
  end

  def load_file(filename)
    raise "no file found " unless File.exist?(filename)
    #figure out file extension , load appropriate class, import the file
    Klass_for(filename).new().import_file(filename)
  end

  def Klass_for(filename)
    case
    when filename.match(/\.pipe$/)
      PipeFile
    when filename.match(/\.csv$/)
      CsvFile
    when filename.match(/\.json/)
      JsonFile
    else
      raise "#{filename} does not have a recognized file type"
    end
  end

  def merge_records_sets(current_inventory, simple_records)
    format_uid = []
    uid = []
    simple_records.each do |row|

      if current_inventory.select{|x| x["uid"].downcase == row["uid"].downcase }.empty? #find the record we are intersted in
        current_inventory.push row
      else
        uid = row["uid"].downcase
        row_format =  row["formats"][0]["format"]
        format_uid =  row["formats"][0]["uid"].downcase

        current_inventory.each do |record|
          if uid == record["uid"].downcase
            formats = record["formats"].select{|x| x["format"].downcase == row_format.downcase}
            if formats.empty?
              record["formats"].push(
              {
                "uid" =>  format_uid.delete(' '),
                "format" => row_format.downcase.eql?("cd") ? row_format.upcase : row_format.capitalize,
                "quantity" => 1
              })
            else
              formats[0]["quantity"] += 1 #increment quantity
            end
          end
        end
      end
    end
    current_inventory
  end

  def output(view_records)
    view_records.each do |record|
      puts "Artist: #{record['artist']}"
      puts "Album:  #{record['title']}"
      puts "Released: #{record['year']}"

      record["formats"].each do |format|
        puts "#{format['format']}(#{format['quantity']}): #{format['uid']}"
      end
      puts ""
    end
  end

  class JsonFile
    def import_file(filename)
      JSON.parse(IO.read(filename))
    end
  end

  class CsvFile
    def import_file(filename,col_sep= ',',headers = %w(artist title format year))
      simple_records = []
      CSV.foreach(filename, {:col_sep => col_sep, :headers => headers}) do |row|
        simple_records.push convert_to_hash(row)
      end
      simple_records
    end
    private
    def convert_to_hash(row)
      uid = row["artist"].to_s + row["title"].to_s + row["year"].to_s
      format_uid = row["artist"].to_s + row["title"].to_s + row["year"].to_s + row["format"].to_s
      row_format = row["format"].to_s
      {
          "uid" =>  uid.delete(' ').downcase,
          "artist" =>  row["artist"],
          "title" =>  row["title"],
          "year" =>  row["year"],
          "formats" =>  [
            {
              "uid" =>  format_uid.delete(' ').downcase,
              "format" => row_format.downcase.eql?("cd") ? row_format.upcase : row_format.capitalize,
              "quantity" =>  1
            }
          ]
      }
    end
   end

  class PipeFile < CsvFile
    def import_file(filename,col_sep=' | ',headers = %w(quanitity format year artist title))
      super(filename,col_sep,headers)
    end

  end
end
