require "thor"
require "version"

require "model/config"

require "controller/do"
require "controller/delete"

require "utils/timestamp"
require "utils/datamap"
require "utils/github"
require "utils/gitapi"
require "utils/string"

# This standard out sync command flushes text destined for STDOUT immediately,
# without waiting either for a full cache or completion.
$stdout.sync = true

# This command line processor extends the Thor gem CLI tools in order to
#
# - read the posted commands, options and switches
# - maps the incoming string data to objects
# - assert that the mandatory options exist
# - assert the type of each parameter
# - ensure that the parameter values are in range
# - delegate processing to the registered handlers

class CLI < Thor

  # This class option allows us to optionally pass a filepath parameter
  # to any usecase.
  class_option :file, :aliases => '-f'



  # Description of the migration do command.
  desc "do", "migrate the repositories from bitbucket to github"

  # The <tt>--dryrun</tt> option conveys that we want to read the configuration
  # and spreadsheet data and carry out as many operations as possible including
  # cloning the source repositories but without making making material changes in
  # state at the github destination.
  method_option :dryrun, :type => :boolean, :aliases => "-d"

  # Migrate repositories from bitbucket to github.
  def do
    do_uc = Migrate::Do.new
    do_uc.dryrun = true if options[ :dryrun ]
    do_uc.dryrun = false unless options[ :dryrun ]
    do_uc.do()
  end



  # Description of the migration delete repositories command.
  desc "delete", "delete the github destination migrated repositories"

  # The <b>delete use case</b> reads config and a spreadsheet and looks
  # to delete destination github repositories created by the do feature.
  def delete
    delete_uc = Migrate::Delete.new
    delete_uc.delete()
  end



  # Printout the version of this command line interface.
  desc "--version", "prints the migrate command line interface version"

  # If <tt>migrate --version</tt> is issued this line accepts it and converts
  # it so that the version method is called.
  map %w[-v --version] => :version

  # Printout the version of this command line interface.
  def version
    puts ""
    puts "migrate gem version => v#{Migrate::VERSION}"
    puts "time and date now  => #{Migrate::TimeStamp.human_readable()}"
    puts ""

  end


end
