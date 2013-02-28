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

    Mongoid.unit_of_work(disable: :all) do

      Parallel.each(files) do |file|

        # load records from file
        reader = MARC::Reader.new(file, :invalid => :replace)

        db_files = []

        reader.each do |record|
          # create a new db_file for this MARC record
          db_file = Model::File.new(:data => record.to_marc, :content_type => 'application/marc')
          db_file.set_created_at

          # add file to mongoid bulk stack
          db_files << db_file.as_document

          if db_files.size > 1000
            Model::File.collection.insert(db_files)
            db_files = []
          end
        end

        # make sure we insert anything left over from the last chunk
        Model::File.collection.insert(db_files)

        puts "Finished importing: #{file}"
      end

    end

  end
end