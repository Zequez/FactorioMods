require 'typhoeus'
require 'nokogiri'

class Subforum < ActiveRecord::Base
  belongs_to :game_version
  has_many :forum_posts

  scope :for_scraping, ->{ where(scrap: true) }

  validates :number, presence: true
  validates :url, presence: true

  def url=(val)
    if val.kind_of? String
      match = val.match(/f=([0-9]+)/)
      self.number = match ? match[1].to_i : nil
    else
      self.number = nil
    end
    super(val)
  end

  def scrap_itself
    doc = Nokogiri::HTML(Typhoeus.get(url).body)
    self.name = doc.search('#page-body > h2 a').text
  end
end
