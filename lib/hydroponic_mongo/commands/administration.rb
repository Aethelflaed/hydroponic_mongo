# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Administration
      extend Base

      command 'listCollections' do
        reply_cursor("#{database.name}.$cmd.listCollections",
                     database.collections.values)
      end

      command 'drop' do
        database.drop

        reply_hash({'dropped' => database.name})
      end
    end
  end
end
