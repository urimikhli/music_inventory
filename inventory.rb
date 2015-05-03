#the inventory
class Inventory
  attr_accessor :records

  INVETORYSTORE = 'db/inventory.json'

  def initialize

    @file = load_file(INVETORYSTORE)
    @records = import_file(INVETORYSTORE)
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
    @file = Klass_for(filename).new(filename)
  end

  def import_file(filename)
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
    end
  end

  class CsvFile
    attr_accessor :records
    def initialize(filename)
      import_file(filename)
    end

    def import_file(filename)
      records = []
      csv_headers = %w('artist','title','format','year')
      raise "no file found " unless File.exist?(filename)
      CSV.foreach(filename, :headers => csv_headers) do |row|
        records.push row
      end
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
