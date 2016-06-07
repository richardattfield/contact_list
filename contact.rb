require 'csv'
require 'pry-byebug'
def menu
  puts "Here is a list of available parameters:"
  puts "new    - Create a new contact"
  puts "list   - List all contacts"
  puts "show   - Show a contact"
  puts "search - Search contacts"
end

menu if ARGV.empty?
ARGV
# binding.pry
# Represents a person in an address book.
# The ContactList class will work with Contact objects instead of interacting with the CSV file directly

class Contact

  attr_accessor :name, :email, :contact, :all_contacts

  # Creates a new contact object
  # @param name [String] The contact's name
  # @param email [String] The contact's email address
  def initialize(name, email)
    # TODO: Assign parameter values to instance variables.
    @name = name
    @email = email

  end

  # Provides functionality for managing contacts in the csv file.
  class << self

    # Opens 'contacts.csv' and creates a Contact object for each line in the file (aka each contact).
    # @return [Array<Contact>] Array of Contact objects
    def all
      # TODO: Return an Array of Contact instances made from the data in 'contacts.csv'.
      contacts = CSV.read('contacts.csv')
      contacts_instances = []
      id = 0
      contacts.each do |contact|
        id += 1
          contacts_instances << [id,Contact.new(contact[1], contact[2])]
      end
      return contacts_instances
    end

    # Creates a new contact, adding it to the csv file, returning the new contact.
    # @param name [String] the new contact's name
    # @param email [String] the contact's email
    def create(name, email)
      # TODO: Instantiate a Contact, add its data to the 'contacts.csv' file, and return it.
      contact_instance = Contact.new(name,email)
      all_contacts = CSV.read('contacts.csv') #array of arrays
      id = 0
      begin
      all_contacts.each do |contact|
        raise "DuplicateEmailError" if contact[2] == email
      end

        id += 1
        contact[0] = id
      end
      all_contacts << [id+1,contact_instance.name,contact_instance.email]
      CSV.open('contacts.csv','w') do |old_contacts|
        all_contacts.each do |new_contacts|
          old_contacts << new_contacts
        end
      end
      return contact_instance
    end

    # Find the Contact in the 'contacts.csv' file with the matching id.
    # @param id [Integer] the contact id
    # @return [Contact, nil] the contact with the specified id. If no contact has the id, returns nil.
    def find(id)
      # TODO: Find the Contact in the 'contacts.csv' file with the matching id.
      # contact_instances = self.all
      contact_instances = all
      contact_instances.find do |contact_instance|
        contact_instance[0] == id
      end

    end

    # Search for contacts by either name or email.
    # @param term [String] the name fragment or email fragment to search for
    # @return [Array<Contact>] Array of Contact objects.
    def search(term)
      # TODO: Select the Contact instances from the 'contacts.csv' file whose name or email attributes contain the search term.
      # contact_instances = self.all
      contact_instances = all
      contact_instances.select do |contact_instance|
        (contact_instance[1].name.match(/#{term}/) || contact_instance[1].email.match(/#{term}/))
      end
    end
  end
end

case ARGV[0]
when "new"
  puts "Please enter first and last name:"
  full_name = STDIN.gets.chomp
  puts "Please enter e-mail address:"
  email = STDIN.gets.chomp
  new_contact = Contact.create(full_name, email)
  puts "New contact successfully created!"
  puts "#{new_contact.name}, #{new_contact.email}"
when "list"
  id = 0
  contacts_instances = Contact.all
  puts "Your contacts are:"
  contacts_instances.each do |contact_instance|
    puts "#{contact_instance[0]}: #{contact_instance[1].name}, (#{contact_instance[1].email})"
    id = contact_instance[0]
  end
  puts "---"
  puts "#{id} records total"
when "show"
  contact_to_show = Contact.find(ARGV[1].to_i)
  if contact_to_show != nil
    puts "#{contact_to_show[1].name}"
    puts "#{contact_to_show[1].email}"
  else
    puts "Contact not found"
  end
when "search"
  contacts_instances = Contact.search(ARGV[1])
  if contacts_instances[0] != nil
    contacts_instances.each do |contact_instance|
      puts "#{contact_instance[0]}: #{contact_instance[1].name}, (#{contact_instance[1].email})"
      id = contact_instance[0]
    end
  else
    puts "Contact not found"
  end
end
# p ARGV[0] #driver - remove at end
