#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'open-uri'
require 'cgi'
require 'json'
require 'date'
require 'colorize'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def json_from(url)
  JSON.parse(open(url).read, symbolize_names: true)
end

def date_from(str)
  return if str.to_s.empty?
  return str if str[/^(\d{4})$/]
  Date.parse(str).to_s
end

def gender_from(str)
  return 'male' if str == 'H'
  return 'female' if str == 'F'
  raise "Unknown gender #{str}"
end

def scrape_list(url)
  json = json_from(url)
  # puts JSON.pretty_generate json
  json[:deputes].each do |d|
    mp = d[:depute]

    data = { 
      id: mp[:id_an],
      name: mp[:nom],
      given_name: mp[:prenom],
      family_name: mp[:nom_de_famille],
      gender: gender_from(mp[:sexe]),
      date_of_birth: mp[:date_naissance],
      area_id: mp[:num_circo],
      area: mp[:nom_circo],
      area_department: mp[:num_deptmt],
      start_date: mp[:mandat_debut],
      end_date: mp[:mandat_fin],
      party: mp[:parti_ratt_financier],
      faction: mp[:groupe_sigle],
      website: mp[:url_an],
      identifier_nos_deputes: mp[:id],
      twitter: mp[:twitter],
      term: 14,
      source: mp[:url_nosdeputes_api],
    }
    ScraperWiki.save_sqlite([:id, :term], data)
  end
end

term = {
  id: '14',
  name: 'XIVe législature de la Ve République',
  start_date: '2012-06-20',
}
ScraperWiki.save_sqlite([:id], term, 'terms')

@URL = 'http://www.nosdeputes.fr/deputes/json'
scrape_list(@URL)
