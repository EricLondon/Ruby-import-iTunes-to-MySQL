module ItunesImport
  # init database
  def self.init(db_params = {})
    @db = Database.new db_params
  end

  # import XML Library into MySQL
  def self.import(itunes_file = nil, options = {})
    # ensure db connection
    raise 'Database connection required.' if @db.nil?

    @itunes_file = itunes_file
    ensure_file

    @db.truncate_table if options.key?(:truncate) && options[:truncate] == true

    load_library

    import_library
  end

  # query
  def self.albums_by_highest_average_rating(limit = 20)
    puts '# Albums by highest average rating:'
    output_results_hash @db.albums_by_highest_average_rating limit
    puts "\n"
  end

  # query
  def self.indie_albums_by_highest_average_rating(limit = 20)
    puts '# Indie Albums by highest average rating:'
    output_results_hash @db.indie_albums_by_highest_average_rating limit
    puts "\n"
  end

  class << self
    private

    def ensure_file
      raise "File (#{@itunes_file}) does not exist" unless File.exist?(@itunes_file)
    end

    def load_library
      @library = Plist.parse_xml @itunes_file
    end

    def import_library
      raise 'Library not loaded' if @library.nil?

      @library['Tracks'].each do |_key, row|
        @db.ensure_columns row.keys
        @db.insert_row row
      end
    end

    def output_results_hash(data = [])
      # max length for each column
      max_lengths = {}
      data.first.keys.each do |column|
        max_row = data.max { |a, b| a[column].to_s.length <=> b[column].to_s.length }
        max_row_column_length = max_row[column].to_s.length
        max_lengths[column] = max_row_column_length > column.length ? max_row_column_length : column.length
      end

      data.each_with_index do |row, index|
        # first row
        if index == 0
          row.each { |key, _value| printf "%-#{max_lengths[key] + 1}s", key }
          puts "\n"
        end

        row.each { |key, value| printf "%-#{max_lengths[key] + 1}s", value }
        puts "\n"
      end
    end
  end
end
