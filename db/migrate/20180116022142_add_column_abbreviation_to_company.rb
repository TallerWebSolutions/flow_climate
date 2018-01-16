# frozen_string_literal: true

class AddColumnAbbreviationToCompany < ActiveRecord::Migration[5.1]
  def change
    add_column :companies, :abbreviation, :string, index: true
    Company.find_by(name: 'Taller')&.update(name: 'Taller Negócios Digitais', abbreviation: 'taller')
    Company.find_by(name: 'CIASC - Centro de Informática e Automação do Estado de Santa Catarina')&.update(abbreviation: 'CIASC')
    change_column_null :companies, :abbreviation, false
  end
end
