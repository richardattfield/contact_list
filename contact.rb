require 'csv'
require 'pry-byebug'
require 'pg'
def menu
  puts "Here is a list of available parameters:"
  puts "new    - Create a new contact"
  puts "list   - List all contacts"
  puts "show   - Show a contact"
  puts "search - Search contacts"
  puts "delete - Delete a contact"
end

menu if ARGV.empty?
ARGV

class Contact

  attr_accessor :name, :email, :contact, :all_contacts, :id
  def self.conn
    PG.connect(
      host: 'localhost',
      dbname: 'contacts_db',
      user: 'development',
      password: 'development'
    )
  end
  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(id=nil, name=nil, email=nil)
    @id = id
    @name = name
    @email = email
  end

  def save
    db_connection = Contact.conn
    if !@id
      result = db_connection.exec('INSERT INTO contacts (name, email) VALUES ($1, $2) RETURNING id;', [@name, @email])
      @id = result.first['id'].to_i
    else
      db_connection.exec('UPDATE contacts SET name = $1, email = $2 WHERE id = $3;', [@name, @email, @id.to_i])
    end
    return self
  end

  def update #called by find or search
    @id = ARGV[1]
    contact_to_update = Contact.find(@id)
    puts "Enter new name:"
    @name = STDIN.gets.chomp
    puts "Enter new email:"
    @email = STDIN.gets.chomp
    save
    return self
  end

  def destroy
    @id = ARGV[1]
    contact_to_destroy = Contact.find(@id)
    return if contact_to_destroy.nil?
    puts "Deleting contact: #{contact_to_destroy.name}"
    Contact.conn.exec('DELETE FROM contacts WHERE id = $1;', [@id.to_i])
    return self
  end

  # Provides functionality for managing contacts in the database file.
  class << self
    # Opens
    # @return [Array<Contact>] Array of Contact objects
    def all
      db_connection = Contact.conn
      db_connection.exec('SELECT * FROM contacts ORDER BY id;')
    end

    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      Contact.new(@id,name,email).save
    end

    # Find the Contact in the 'contacts db' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      db_connection = Contact.conn
      obj = db_connection.exec('SELECT * FROM CONTACTS WHERE id=$1::int;',[id])
      Contact.new(obj.first["id"],obj.first["name"],obj.first["email"]) unless obj.first.nil?
    end

    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      db_connection = Contact.conn
      db_connection.exec("SELECT * FROM contacts WHERE name LIKE '#{term}%';")
    end

    def add_contact
      puts "Please enter first and last name:"
      full_name = STDIN.gets.chomp
      puts "Please enter e-mail address:"
      email = STDIN.gets.chomp
      new_contact = Contact.create(full_name, email)
      puts "New contact successfully created!"
      print_output(new_contact)
    end

    def print_output(contacts, show = false)
      input_type = contacts.class
      puts "***Contact not found!***" if input_type.to_s == "NilClass"
      case input_type.to_s
      when "Contact"
        message = "Contact found" if show
        message = "Contact added, removed, or updated" unless show
        puts "---------"
        puts "#{message}: #{contacts.name}   #{contacts.email}"
        puts "---------"
      when "PG::Result"
        contacts.each do |contact|
          puts "#{contact["id"]} #{contact["name"]}, #{contact["email"]}"
        end
        puts "***No results!***" if contacts.first.nil?
      end
    end
  end
end

case ARGV[0]
when "new"
  Contact.add_contact
when "list"
  contacts_instances = Contact.all
  puts "Your contacts are:"
  Contact.print_output(contacts_instances)
  puts "---------"
when "show"
  contact_to_show = Contact.find(ARGV[1].to_i)
  Contact.print_output(contact_to_show, true)
when "search"
  contacts_to_show = Contact.search(ARGV[1])
  Contact.print_output(contacts_to_show)
when "update"
  result = Contact.new.update
  Contact.print_output(result)
when "delete"
  result = Contact.new.destroy
  Contact.print_output(result)
end
