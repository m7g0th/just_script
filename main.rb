require 'nokogiri'
require 'open-uri'
require 'csv'
require 'ruby-progressbar'

#---
# Parse by number v0.0.4
#
# parse content from service http://aclist.ru
#
# threepwoodg
#---

def request(number)
  Nokogiri::HTML(open("http://aclist.ru/site/check?phone=#{number}")).css('.content__title').each do |content|
    time = Time.new()
    CSV.open("lib/output-#{time.strftime("%H:%M-%d-%m-%Y")}.csv", 'a+') do |csv|
      csv << ["#{number.last.to_i} : #{content.content}"]
    end
  end
end

def read_file(path)
  progressbar = ProgressBar.create(:format=> "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :starting_at => 0)
  progressbar.total = open(path).read.count("\n")
    CSV.foreach(path) do |row|
      request(row)
      progressbar.increment
    end
end

read_file('lib/input.txt')