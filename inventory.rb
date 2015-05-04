#the inventory
#
require 'csv'
require 'json'

class Inventory
  attr_accessor :records, :file, :new_records

  INVETORYSTORE = 'db/inventory.json'

  def initialize
    puts INVETORYSTORE
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
    raise "no file found " unless File.exist?(filename)
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
    attr_accessor :records, :uids
    def initialize(filename)
      import_file(filename)
    end

    def import_file(filename)
      records = []
      csv_headers = %w('artist' 'title' 'format' 'year')
      CSV.foreach(filename, :headers => csv_headers) do |row|
        puts row.inspect
        convert_to_inventory(row,records)
      end
      records
    end
    private
    def convert_to_inventory(row, records)
      uid = row["'artist'"].to_s + row["'title'"].to_s + row["'year'"].to_s
      if uids.select{|x| x.match(uid)} #does this record exist yet
        self.records.each do |record|
          if record["uid"].match(uid) #find the record we are intersted in
            if record["formats"].select{|x| x.format.match(row["format"])} #does the format already exist
              record["formats"].each do |format|
                if format["format"].match(row["format"]) #find format we are intersted in
                  format["quantity"] += 1 #increment quantity
                  break
                end
              end
            else #new format for this item
              record["formats"].push(
                  {
                  "uid":  uid + row["format"].to_s,
                  "format": row["format"],
                  "quantity": 1
                  })
            end
            break
          end
        end
      else #create the record
        uids.push(row["artist"] + row["title"] + row["year"] + row["format"])
        records.push (
        {
          "uid": row["artist"] + row["title"] + row["year"]
          "artist": row["artist"],
          "title": row["title"],
          "year": row["year"],
          "formats": [
            {
              "uid":  row["artist"] + row["title"] + row["year"] + row["format"],
              "format": row["format"],
              "quantity": 1
            }
          ]
        }
        )

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
