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

    puts "Importing #{files.size} MARC file(s) using #{[files.size, Parallel.processor_count].min} processors..."

    Parallel.each(files) do |file|

      # load records from file
      reader = MARC::Reader.new(file)

      reader.each do |record|

        # ensure we are importing valid UTF-8 MARC
        marc = record.to_marc

        if !marc.valid_encoding?# or !marc.force_encoding('UTF-8').valid_encoding?
          puts 'Detected bad encoding, fixing...'
          marc = marc.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
          marc = marc.encode!('UTF-8', 'UTF-16')
        end

        # create a new resource for this MARC record
        Resource.new({:marc => marc}).save
      end

      puts "Finished importing: #{file}"
    end
  end
end