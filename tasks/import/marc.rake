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

#    mime = MIME::Type.new(FileMagic.fm(:mime).buffer(data_string))

    files.each do |file_name|
      records = MARC::ForgivingReader.new(file_name, :invalid => :replace) # TODO: may wish to include encoding options

      Parallel.each(records) do |marc_record|
        # POST the MARCHASH to Ladder
        RestClient.post 'http://localhost/files/?map=true', marc_record.to_marchash.to_json, :content_type => 'application/marc+json'
      end
    end
=begin
    Mongoid.unit_of_work(disable: :all) do
      Parallel.each(files) do |file_name|
        puts "Finished importing_name: #{file}"
      end
    end
=end
  end
end