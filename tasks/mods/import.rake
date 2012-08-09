desc "Import data from MODS XML file(s)"

namespace :mods do
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

    puts "Importing records from #{files.size} MODS file(s) using #{Parallel.processor_count} processors..."

    Parallel.each(files) do |file|
      # Make sure to reconnect after forking a new process
      Mongoid.reconnect!

      resources = []
      size = 0

      files.each do |file|

        # create a new resource for this MODS file
        resource = Resource.new
        resource.set_created_at
        resource.mods = IO.read(file)

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