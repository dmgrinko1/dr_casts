# frozen_string_literal: true

require 'mechanize'
require 'nokogiri'
require 'open-uri'

class CrawlerBase

  attr_reader :from, :to

  def initialize(from:, to:)
    @from = from
    @to = to
  end

  def call
    run_crawler
  end
end