# frozen_string_literal: true

class BaseGraphqlObject
  attr_reader :total_count, :last_page, :total_pages

  def initialize(total_count, last_page, total_pages)
    @total_count = total_count
    @last_page = last_page
    @total_pages = total_pages
  end
end
