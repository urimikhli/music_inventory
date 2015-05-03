#the inventory
class Inventory
  attr_accessor @records

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

end
