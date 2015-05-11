#the inventory
#
require 'csv'
require 'json'
require 'byebug'

class Inventory
  attr_accessor :records, :new_records

  INVETORYSTORE = 'db/inventory.json'

  def initialize
    @records = load_file(INVETORYSTORE.to_s)
  end

  def load_new_inventory(filename)
    @new_records = load_file(filename)
    persist(merge_records_sets(records,new_records))
  end

  def search_inventory(search_field, query)
  end

  def purchase(uid)
  end

  private

  def merge_records_sets(new, current)
  end

  def persist(inventory_records)
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
      convert_to_inventory(simple_records)
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
    def convert_to_inventory(simple_records)
      format_uid = []
      uid = []
      new_records = []
      simple_records.each do |row|

        if new_records.select{|x| x["uid"] == row["uid"]}.empty? #find the record we are intersted in
          new_records.push row
        else
          uid = row["uid"]
          row_format =  row["formats"][0]["format"]
          format_uid =  row["formats"][0]["uid"]

          new_records.each do |record|
            if uid == record["uid"]
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
      new_records
    end
  end

  class PipeFile < CsvFile
    def import_file(filename,col_sep=' | ',headers = %w(quanitity format release year artist title))
      super(filename,col_sep,headers)
    end

  end
end
