#the inventory
#
require 'csv'
require 'json'
require 'byebug'

class Inventory
  attr_accessor :records, :file, :new_records

  INVETORYSTORE = 'db/inventory.json'

  def initialize
    @file = load_file(INVETORYSTORE.to_s)
    @records = import_file(INVETORYSTORE.to_s)
  end

  def load_new_inventory(filename)
    @file = load_file(filename)
    @new_records = import_file(filename)
  end

  def search_inventory(search_field, query)
  end

  def purchase(uid)
  end

  private

  def load_file(filename)
    raise "no file found " unless File.exist?(filename)
    #figure out file extension , load appropriate class, import the file
    @file = Klass_for(filename).new(filename)
  end

  def import_file(filename)
    raise "no file found #{filename}" unless File.exist?(filename)
    file.import_file(filename)
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
    attr_accessor :records
    def initialize(filename)
      import_file(filename)
    end

    def import_file(filename)
      JSON.parse(IO.read(filename))
    end
  end

  class CsvFile
    attr_accessor :new_records
    def initialize(filename)
      import_file(filename)
    end

    def import_file(filename)
      new_records = []
      csv_headers = %w(artist title format year)
      CSV.foreach(filename, :headers => csv_headers) do |row|
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

  class PipeFile
    attr_accessor :records
    def initialize(filename)
      import_file(filename)
    end

    def import_file(filename)
    end
  end
end
