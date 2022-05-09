# frozen_string_literal: true

module Types
  class SortDirection < Types::BaseEnum
    value 'ASC', 'order the results in ascending order'
    value 'DESC', 'order the results in descending order'
  end
end
