desc "Import data from MARC binary file(s)"

namespace :import do
  task :marc, [:file] => :environment do |t, args|

    if args.file.nil?
      abort('No filename specified.')
    end

    path = File.expand_path(args.file, __FILE__)

    if File::directory? path
      files = Dir.entries(path).reject! {|s| s =~ /^\./}  # don't include dotfiles
      files.map! {|file| File.join(path, file)}

      # order largest files first so processes aren't blocking
      files = files.sort_by {|filename| File.size(File.expand_path(filename, args.file)) }.reverse
    else
      files = [path]
    end

    puts "Importing #{files.size} MARC files using #{[files.size, Parallel.processor_count].min} processors..."

    # create an importer for this content
    importer = Importer.create('application/marc')

    Mongoid.unit_of_work(disable: :all) do

      Parallel.each(files) do |file_name|

        importer.import(File.open(file_name), 'application/marc')

        puts "Finished importing_name: #{file}"
      end

    end

  end
end