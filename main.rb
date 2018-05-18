require 'nokogiri'
require 'open-uri'
require 'csv'
require 'ruby-progressbar'
require 'spreadsheet'

system('cls') # windows
system('reset') # linux

#---
# Parse by number v0.0.9
#
# parse content from service http://aclist.ru
# parse content from service https://cheinomer.ru/
#
# threepwoodg
# m7g
#---

def request(number)
  aclist_parse = Nokogiri::HTML(open("http://aclist.ru/site/check?phone=#{number.last}"))
  cheinomer_parse = Nokogiri::HTML(open("https://cheinomer.ru/telefona/?n=#{number.last}"))
  number_content = aclist_parse.css('.content__title')
  @sheet1[@i,0] = number.last.to_i
  @sheet1[@i,1] = number_content[0].content
  begin
    company = cheinomer_parse.css('.alert-info strong')
    @sheet1[@i,2] = company[2].content
    extra = []
    cheinomer_parse.css('.tvebuttoncolor').each do |dop|
      extra << dop.content if /\+/=~dop.content
    end
    @sheet1[@i,3] = extra.last
    region = cheinomer_parse.css('.entry-content h2')
    if /Регион номера+/=~region[0].content
      @sheet1[@i,4] = region[0].content
    elsif /Регион номера+/=~region[1].content
      @sheet1[@i,4] = region[1].content
    end
  rescue
    @sheet1[@i,2] = "Номер не найден в базе"
  end
  @i = @i + 1
end

def read_file(path)
  progressbar = ProgressBar.create(:format=> "%a %b\u{003E}%i %p%% %t", :progress_mark  => "\u{0023}", :remainder_mark => " ", :starting_at => 0)
  progressbar.total = open(path).read.count("\n")
  book = Spreadsheet::Workbook.new
  @sheet1 = book.create_worksheet
  @sheet1.name = 'worksheet'
  @sheet1[0,0] = 'Номер'
  @sheet1[0,1] = 'Результат с сайта aclist.ru'
  @sheet1[0,2] = 'Результат с сайта cheinomer.ru'
  @sheet1[0,3] = 'Дополнителная сведенья с сайта cheinomer.ru (если имеются)'
  @sheet1[0,4] = 'Регион'
  @i = 1
  CSV.foreach(path) do |row|
    request(row)
    progressbar.increment
  end
  time = Time.new()
  book.write "lib/#{time.strftime("%Y-%m-%d-%H-%M-%S")}.xls"
end

read_file('lib/input.txt')
