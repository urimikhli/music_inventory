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
      new_records = []
      CSV.foreach(filename, {:col_sep => col_sep, :headers => headers}) do |row|
         new_records.push convert_to_inventory(row)
      end
      new_records
    end
    private
    def convert_to_inventory(row)
      #dont care about the dupes, can get rid of them more easily when merging into the inventory records
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
