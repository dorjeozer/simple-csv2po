#!/usr/bin/ruby -w

unless ARGV.length == 2
  puts "Usage: convert <csv-file> <po-file>"
  exit
end

def write2po(type, word="")
  if type.eql? "msgid"
    @po_path << 'msgid "'+word+'"'
  elsif type.eql? "msgstr"
    @po_path << 'msgstr "'+word+'"'
    @po_path << "\n"
  else
    @po_path << word
    @po_path << "\n"
  end
  @po_path << "\n"
end

@po_file_header = '# SOME DESCRIPTIVE TITLE.
# Copyright (C) YEAR THE PACKAGE\'S COPYRIGHT HOLDER
# This file is distributed under the same license as the PACKAGE package.
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid ""
msgstr ""
"Project-Id-Version: PACKAGE VERSION\n"
"Report-Msgid-Bugs-To: \n"
"POT-Creation-Date: 2014-04-17 12:27+0300\n"
"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\n"
"Last-Translator: FULL NAME <EMAIL@ADDRESS>\n"
"Language-Team: LANGUAGE <LL@li.org>\n"
"Language: \n"
"MIME-Version: 1.0\n"
"Content-Type: text/plain; charset=UTF-8\n"
"Content-Transfer-Encoding: 8bit\n"'

begin
  @field_separator = "|"
  @csv_path = File.open ARGV[0], "r"
  @po_path = File.open ARGV[1], "w"
  write2po("header", @po_file_header)
  original_language = true
  msgid = ""
  msgstr = ""
  @csv_path.each_char do |c|
    if c.eql? @field_separator
      write2po("msgid", msgid)
      original_language = false
    else 
      unless c.eql? "\n"
        if c.eql? '"'
          if original_language
            msgid += '\\'
          else
            msgstr += '\\'
          end
        end
        if original_language
          msgid += c
        else
          msgstr += c
        end
      else
        if msgid.eql? msgid.upcase
          msgstr.upcase!
        end
        write2po("msgstr", msgstr)
        original_language = true
        msgid.clear
        msgstr.clear
      end
    end
  end

  @po_path.close
  @csv_path.close

  puts "Conversion ready."
rescue Errno::ENOENT
  puts "Could not open "+ARGV[0]
rescue Errno::EACCES
  puts "Permission denied"
rescue IOError
  puts "Could not write to "+ARGV[1]
end
