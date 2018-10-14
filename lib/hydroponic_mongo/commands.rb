# frozen_string_literal: true

require 'hydroponic_mongo/commands/database'
require 'hydroponic_mongo/commands/collection'

module HydroponicMongo
  module Commands
    include HydroponicMongo::Commands::Database
    include HydroponicMongo::Commands::Collection
  end
end
