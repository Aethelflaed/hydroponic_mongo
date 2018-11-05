# frozen_string_literal: true

require 'hydroponic_mongo/commands/base'
require 'hydroponic_mongo/commands/aggregation'
require 'hydroponic_mongo/commands/query_and_write_operation'
require 'hydroponic_mongo/commands/administration'

module HydroponicMongo
  module Commands
    include HydroponicMongo::Commands::Aggregation
    include HydroponicMongo::Commands::QueryAndWriteOperation
    include HydroponicMongo::Commands::Administration
  end
end
