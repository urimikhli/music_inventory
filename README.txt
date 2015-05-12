Discussion:

There are many opportunities to improve this code. I purposly kept duplications and allowed conditionals so that the refactor path would be a little clearer. The next step has to be a set of tests that backstop the behavior of the Inventory API (load_inventory, search_inventory, purchase.) With those in place I can refactor towards better, more OO code.

Next Steps, in no particular order other then build tests first:

- Tests of inventory api
- One of the things to consider in a refactoring is perhaps the creation of a Record class to do away with the majority of the Hash logic... Which I dislike, but is easier for me to conceptualize when under the gun.
- The inheritance of PipFile from CsvFile is suspect... Should investigate maybe creating a role class called Delimiter.
- Better originization of code. Put Inventory.rb in lib/ split out the sub classes into their own file. Any new classes that are built would go as files in lib

Note:
- If not for the restriction on Ruby core libs I would have just used ActiveRecord to make this whole object alot simpler.


Original Instructions:
---------------------
---------------------

Overview
--------
For this exercise, you will be writing a small program to help manage the inventory for a little record store. The program will be able to do 3 things: load delivery manifests from text files, search inventory, and remove items from the inventory. Each item in the inventory is described by the artist's name, the album title, the release year of the album, and the media format.


Interface
---------
The interface is composed of 3 commands:

load_inventory
 - Takes one parameter, the name of a file that contains a shipping manifest
 - The manifests come in two different formats, described below

search_inventory
 - Takes two parameters, a field name and a search substring.
 - Returns the descriptions of matching items in the format specified below.
 - Results are ordered ascending on the search field name, except for release year and media format, which are descending.
 - Each description includes an identifier unique to that inventory entry.

purchase
 - takes one parameter, the unique identifier


Characteristics of a Solution
-----------------------------
We realize this is a small exercise, but we are looking to understand how you write and refine code. Please develop your solution as you would any production-ready solution.

As far as mechanics:
 - Use Ruby and only the core Ruby libraries (including the Ruby standard libraries: i.e. json, etc.).
 - Each command should be a separate script.

We will be evaluating your submission based on the following aspects:
 - Functionality: It should work and adhere to this prompt.
 - An appropriate level of design
 - Clarity of code
 - Maintainability and extensibility


Input Formats
-------------
The two formats are pipe-delimited and comma-separated.

The pipe-delimited format has the columns in the following order:
 Quanitity | Format | Release year | Artist | Title

The comma-separated format has one line per inventory item, with the columns in the following order:
 Artist,Title,Format,Release year

It's also worth noting that the venders aren't always the most reliable with their casing, etc. Make sure we don't end up with entries that differ only by casing of one of their fields, e.g. "Simon & Garfunkel" and "Simon & GARFunkle"


Output format
-------------
The results of a search should be printing in the format below with one line separating each record.

Artist: <artist name>
Album: <album title>
Released: <release year>
CD(<cd quantity>): <cd inventory identifier>
Tape(<tape quantity>): <tape inventory identifier>
Vinyl(<vinyl quantity>): <vinyl inventory identifier>


Example run
-----------
$ ruby load_inventory.rb cd_sellers.csv
$ ruby search_inventory.rb artist Nas
Artist: Nas
Album: Illmatic
Released: 1994
CD(2): <uid>
Vinyl(1): <uid>
$ ruby load_inventory.rb music_merchant.csv
$ ruby search_inventory.rb album matic
Artist: Nas
Album: Illmatic
Released: 1994
Tape(2): <uid>
Vinyl(1): <uid>

Artist: Nas
Album: Stillmatic
Released: 2001
CD(2): <uid>
Vinyl(1): <uid for Stillmatic vinyl>
$ ruby purchase.rb <uid for Stillmatic vinyl>
Removed 1 vinyl of Stillmatic by Nas from the inventory
$ ruby search_inventory.rb album stillmatic
Artist: Nas
Album: Stillmatic
Released: 2001
CD(2): <uid>
$

