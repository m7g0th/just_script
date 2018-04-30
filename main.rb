require 'nokogiri'
require 'open-uri'
require 'csv'
require 'ruby-progressbar'
require 'spreadsheet'

#---
# Parse by number v0.0.8
#
# parse content from service http://aclist.ru
#
# threepwoodg
#---

def request(number)
  Nokogiri::HTML(open("http://aclist.ru/site/check?phone=#{number.last}")).css('.content__title').each do |content|
    @sheet1[@i,0] = number.last.to_i
    @sheet1[@i,1] = content.content
  end
  begin
    company = Nokogiri::HTML(open("https://cheinomer.ru/telefona/?n=#{number.last}")).css('.alert-info strong')
    @sheet1[@i,2] = company[2].content.chop
    Nokogiri::HTML(open("https://cheinomer.ru/telefona/?n=#{number.last}")).css('.tvebuttoncolor').each do |name|
      @sheet1[@i,3] = name.content if /\+/=~name.content
    end
  rescue
    @sheet1[@i,2] = "Номер не найден в базе"
  end
  @i = @i + 1
end

def read_file(path)
  progressbar = ProgressBar.create(:format=> "%a %b\u{15E7}%i %p%% %t", :progress_mark  => ' ', :remainder_mark => "\u{FF65}", :starting_at => 0)
  progressbar.total = open(path).read.count("\n")
  book = Spreadsheet::Workbook.new
  @sheet1 = book.create_worksheet
  @sheet1.name = 'worksheet'
  @sheet1[0,0] = 'Номер'
  @sheet1[0,1] = 'Результат с сайта aclist.ru'
  @sheet1[0,2] = 'Результат с сайта cheinomer.ru'
  @sheet1[0,3] = 'Дополнителная сведенья с сайта cheinomer.ru (если имеются)'
  @i = 1
  CSV.foreach(path) do |row|
    request(row)
    progressbar.increment
  end
  time = Time.new()
  book.write "lib/#{time.strftime("%H:%M-%d-%m-%Y")}.xls"
end

read_file('lib/input.txt')