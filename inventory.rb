#the inventory
class Inventory
  attr_accessor :records

  INVETORYSTORE = 'db/inventory.json'

  def initilize
    @records = load_file(INVETORYSTORE)
  end

  def load_new_inventory(filename)
  end

  def search_inventory(search_field, query)
  end

  def purchase(uid)
  end

  private

  def load_file(filename)
    raise "no file found " unless File.exist?(filename)
    #figure out file extension , load appropriate class, import the file
    @records = Klass_for(filename).import_file(filename)

  end

  def Klass_for(filename)
    case filename
    when /\.pipe$/.match(filename)
      PipeFile
    when /\.csv$/.match(filename)
      CsvFile
    when /\.json/.match(filename)
      JsonFile
    else
      raise "#{filename} does not have a recognized file type"
    end
  end

  class JsonFile
    def self.import_file(filename)
    end
  end

  class CsvFile
    def self.import_file(filename)
      records = []
      csv_headers = %w('artist','title','format','year')
      raise "no file found " unless File.exist?(filename)
      CSV.foreach(filename, :headers => csv_headers) do |row|
        records.push row
      end
    end
  end

  class PipeFile
    def self.import_file(filename)
    end
  end
end
