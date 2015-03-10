#!/usr/bin/env ruby
require "scraperwiki"
require "mechanize"

agent = Mechanize.new

url = "https://online.foi.vic.gov.au/CA256BE9002028C5/Agency?ReadForm&1=20-Find+an+agency~&2=05-Browse+by+agency+name~&3=~&Letter=B&Agency=118~"
page = agent.get url

table = page.at('div.DOCbody').at(:table)
agency_values = table.search('td.AgencyValue').map { |td| td.inner_text }

record = {
  id:             url[/\=(\d+)~$/, 1],
  name:           page.at(:h2).inner_text,
  postal_address: agency_values[0].gsub("\n", ", "),
  street_address: agency_values[1].gsub("\n", ", "),
  telephone:      agency_values[2],
  fax:            agency_values[3],
  email:          agency_values[4],
  website:        table.search(:a)[1].attr(:href)
}

# ScraperWiki.save_sqlite([:id], record)
p record
