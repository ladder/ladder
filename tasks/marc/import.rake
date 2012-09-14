desc "Import data from MARC binary file(s)"

namespace :marc do
  task :import, [:file] => :environment do |t, args|

    if args.file.nil?
      abort('No filename specified.')
    end

    path = File.expand_path(args.file, __FILE__)

    if File::directory? path
      files = Dir.entries(path).reject! {|s| s =~ /^\./}  # don't include dotfiles
      # order largest files first so processes aren't blocking
      files = files.sort_by {|filename| File.size(File.expand_path(filename, args.file)) }.reverse
    else
      files = [path]
    end

    puts "Importing records from #{files.size} MARC file(s) using #{Parallel.processor_count} processors..."

    Parallel.each(files) do |file|

      # load records from file
      reader = MARC::Reader.new(File.join(path, file))

      resources = []
      size = 0

      reader.each do |record|

        # create a new resource for this MARC record
        resource = Resource.new
        resource.set_created_at

        # ensure we are importing valid UTF-8 MARC
        marc = record.to_marc

        if marc.force_encoding('UTF-8').valid_encoding?
          resource.marc = marc
        else
          resource.marc = marc.encode!('UTF-8', 'UTF-8', :invalid => :replace)
        end

        # add resource to mongoid bulk stack
        r = resource.as_document
        resources << r

        # use 128KB chunks (empirically seems fastest)
        size += BSON.serialize(r).size
        if size > 131000
          Resource.collection.insert(resources)
          resources = []
          size = 0
        end

      end

      # make sure we insert anything left over from the last chunk
      Resource.collection.insert(resources)

      puts "Finished importing: #{file}"
    end
  end
end