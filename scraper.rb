#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'scraperwiki'
require 'open-uri'
require 'cgi'
require 'json'
require 'date'

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
  json[:deputes].map do |d|
    mp = d[:depute]
    data = {
      id:                             mp[:id_an],
      name:                           mp[:nom],
      given_name:                     mp[:prenom],
      family_name:                    mp[:nom_de_famille],
      gender:                         gender_from(mp[:sexe]),
      date_of_birth:                  mp[:date_naissance],
      area:                           mp[:nom_circo],
      area__subdivision:              mp[:num_circo],
      area_department:                mp[:num_deptmt],
      start_date:                     mp[:mandat_debut],
      end_date:                       mp[:mandat_fin],
      party:                          mp[:parti_ratt_financier],
      faction:                        mp[:groupe_sigle],
      website:                        mp[:url_an],
      identifier_nos_deputes:         mp[:id],
      identifier_assemblee_nationale: mp[:id_an],
      twitter:                        mp[:twitter],
      term:                           14,
      source:                         mp[:url_nosdeputes_api],
    }
  end
end

data = scrape_list 'https://www.nosdeputes.fr/deputes/json'
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id term], data)
