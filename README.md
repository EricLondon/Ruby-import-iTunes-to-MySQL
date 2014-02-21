Ruby-import-iTunes-to-MySQL
===========================

Ruby import iTunes to MySQL

Please read blog post: http://ericlondon.com/2014/02/20/ruby-import-itunes-to-mysql.html

General Usage:

Git clone this repo from GitHub:
```bash
git clone git@github.com:EricLondon/Ruby-import-iTunes-to-MySQL.git
```

From iTunes, export your library. It's easiest of you put this XML file in your cloned repo directoy.
```bash
File >> Library >> Export Library...
Save As: Library.xml
```

Installed required Ruby gems:
```bash
bundle install
```

Execute.
```bash
# you'll need to update your local database credentials first
./main.rb
```

