#!/usr/bin/env ruby
require "scraperwiki"
require "mechanize"

def save_agency(page)
  table = page.at('div.DOCbody').at(:table)
  agency_values = table.search('td.AgencyValue').map { |td| td.inner_text }

  website = table.search(:a)[1] ? table.search(:a)[1].attr(:href) : nil

  record = {
    id:             page.uri.to_s[/\=(\d+)~$/, 1],
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

url = "https://online.foi.vic.gov.au/CA256BE9002028C5/Agency?ReadForm&1=20-Find+an+agency~&2=05-Browse+by+agency+name~&3=~&Letter=B&Agency=118~"
page = agent.get url

save_agency(page)
