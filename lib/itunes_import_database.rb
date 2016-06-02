module ItunesImport
  class Database
    attr_reader :mysql

    def initialize(params = {})
      params.each { |key, value| instance_variable_set("@db_#{key}", value.to_s) }

      db_init
      ensure_database
      ensure_table
    end

    def db_init
      @mysql = Mysql2::Client.new host: @db_host, username: @db_username, password: @db_password, database: @db_database
    end

    def ensure_database
      sql = "show databases like '#{@mysql.escape(@db_database)}'"
      raise "Database (#{@mysql.escape(@db_database)}) does not exist" if @mysql.query(sql).map { |r| r }.empty?
    end

    def ensure_table
      sql = "show tables in #{@mysql.escape(@db_database)} like '#{@mysql.escape(@db_table)}'"
      results = @mysql.query(sql).first

      if results.nil?
        sql = "CREATE TABLE `#{@mysql.escape(@db_table)}` (id INT(11) UNSIGNED NOT NULL PRIMARY KEY AUTO_INCREMENT)"
        @mysql.query sql
      end
    end

    def ensure_columns(columns = [])
      # get a list of existing columns
      sql = "show columns in #{@mysql.escape(@db_table)}"
      existing_columns = @mysql.query(sql).map { |r| r['Field'] }

      # ensure columns exist
      columns.each do |column|
        unless existing_columns.include?(column)
          sql = "ALTER TABLE #{@mysql.escape(@db_table)} ADD `#{column}` VARCHAR(255)"
          @mysql.query sql
        end
      end
    end

    def insert_row(row)
      sql_columns = row.keys.map { |k| "`#{k}`" }.join(', ')
      sql_values = row.values.map { |v| "'#{@mysql.escape(v.to_s[0..254])}'" }.join(', ')

      sql = "insert into #{@mysql.escape(@db_table)} (#{sql_columns}) values (#{sql_values})"
      @mysql.query sql
    end

    def truncate_table
      sql = "select count(*) as `countX` from `#{@mysql.escape(@db_table)}`"
      return if @mysql.query(sql).first['countX'] == 0

      sql = "truncate table `#{@mysql.escape(@db_table)}`"
      @mysql.query sql
    end

    def albums_by_highest_average_rating(limit = 20)
      sql = "
        select Artist, Album, Genre, Year, count(*) as `album_track_count`, avg(ifnull(Rating, 0)) as `average_rating`
        from tracks
        where `Album Artist` is not null
        group by `Album Artist`, Album
        having album_track_count > 2
        order by average_rating desc
        limit #{@mysql.escape(limit.to_s)}"

      @mysql.query(sql).map { |result| result }
    end

    def indie_albums_by_highest_average_rating(limit = 20)
      sql = "
        select Artist, Album, Genre, Year, count(*) as `album_track_count`, avg(ifnull(Rating, 0)) as `average_rating`
        from tracks
        where `Album Artist` is not null and Genre like '%indie%'
        group by `Album Artist`, Album
        having album_track_count > 2
        order by average_rating desc
        limit #{@mysql.escape(limit.to_s)}"

      @mysql.query(sql).map { |result| result }
    end
  end
end
