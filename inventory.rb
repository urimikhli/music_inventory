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

  def search_inventory(search_field, query)
  end

  def purchase(uid)
  end

  private

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
            formats = record["formats"].select{|x| x["format"] == row_format}
            if formats.empty?
              record["formats"].push(
              {
                "uid" =>  format_uid,
                "format" => row_format,
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
      {
          "uid" =>  row["artist"].to_s + row["title"].to_s + row["year"].to_s,
          "artist" =>  row["artist"],
          "title" =>  row["title"],
          "year" =>  row["year"],
          "formats" =>  [
            {
              "uid" =>   row["artist"].to_s + row["title"].to_s + row["year"].to_s + row["format"].to_s,
              "format" =>  row["format"],
              "quantity" =>  1
            }
          ]
        }
    end
   end

  class PipeFile < CsvFile
    def import_file(filename,col_sep=' | ',headers = %w(quanitity format release year artist title))
      super(filename,col_sep,headers)
    end

  end
end
