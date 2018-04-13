# frozen_string_literal: true

class CollectionsService
  def self.find_nearest(array, value)
    array.min_by { |element| (value - element).abs }
  end
end
