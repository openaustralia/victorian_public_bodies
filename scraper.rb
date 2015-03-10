#!/usr/bin/env ruby
require "scraperwiki"
require "mechanize"

def save_agency(page)
  id = page.uri.to_s[/\=(\d+)~$/, 1]
  if id.nil?
    puts "Skipping missing ID for URL: #{page.uri.to_s}"
    return false
  end

  table = page.at('div.DOCbody').at(:table)
  agency_values = table.search('td.AgencyValue').map { |td| td.inner_text }

  website = table.search(:a)[1] ? table.search(:a)[1].attr(:href) : nil

  record = {
    id:             id,
    name:           page.at(:h2).inner_text,
    postal_address: agency_values[0].gsub("\n", ", "),
    street_address: agency_values[1].gsub("\n", ", "),
    telephone:      agency_values[2],
    fax:            agency_values[3],
    email:          agency_values[4],
    website:        website
  }

  ScraperWiki.save_sqlite([:id], record)
end

agent = Mechanize.new
base_url = "https://online.foi.vic.gov.au"

('A'...'Z').each do |letter|
  index_url = "/CA256BE9002028C5/AgencyLetter?ReadForm&1=20-Find+an+agency~&2=05-Browse+by+agency+name~&3=~&Letter=#{letter}~"
  page = agent.get(base_url + index_url)

  page.search('a.agency').each do |link|
    agency_page = agent.get(base_url + link.attr(:href))
    puts "Saving #{link.inner_text}:\n#{agency_page.uri.to_s}"
    save_agency(agency_page)
  end
end
