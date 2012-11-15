desc "Import data from MODS XML file(s)"

namespace :import do
  task :mods, [:file] => :environment do |t, args|

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

    puts "Importing #{files.size} MODS file(s) using #{[files.size, Parallel.processor_count].min} processors..."

    Mongoid.unit_of_work(disable: :all) do

      Parallel.each(files) do |file|

        # create a new resource for this MODS file
        # NB: we don't do this in batch because files may be large (multiple MB)
        Resource.new({:mods => IO.read(file)})

        puts "Finished importing: #{file}"
      end

    end

  end
end