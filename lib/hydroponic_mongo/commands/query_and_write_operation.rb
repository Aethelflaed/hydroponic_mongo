# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module QueryAndWriteOperation
      extend Base

      command 'insert' do
        n = cmd['documents'].map do |document|
          collection.insert_one(document)
        end.uniq.count
        reply_hash({'n' => n})
      end

      command 'find' do
        query = Query.new(cmd['filter'], collection.documents, cmd)

        # TODO:
        # Handle options:
        # - cmd['projection']

        reply_cursor("#{database.name}.#{collection.name}",
                     query.documents)
      end

      command 'update' do
        rval = {'n' => 0, 'nModified' => 0}
        n, nModified = 0, 0
        upserted = []

        cmd['updates'].each_with_index do |update, index|
          begin
            n, nModified, upserted = collection.update(update['q'], update['u'], update)
            rval['n'] += n
            rval['nModified'] += nModified

            if upserted.present?
              rval['upserted'] ||= []
              upserted.each do |id|
                rval['upserted'].push({
                  'index' => index,
                  '_id' => id,
                })
              end
            end
          rescue HydroponicMongo::WriteError => e
            rval['writeErrors'] ||= []
            rval['writeErrors'].push({
              'index'  => index,
              'code'   => e.code,
              'errmsg' => e.messag
            })
          end
        end

        reply_hash(rval)
      end

      command 'findAndModify' do
        rval = {
          'value' => nil,
          'lastErrorObject' => {
            'updatedExisting' => false,
            'upserted' => {},
          }
        }

        query_options = {'limit' => 1}
        if cmd['sort']
          query_options['sort'] = cmd['sort']
        end

        query = Query.new(cmd['query'], collection.documents, query_options)
        document = query.documents.first

        if document
          rval['value'] = document

          if cmd['remove']
            collection.delete_one(document['_id'])
          else # update
            rval['lastErrorObject']['updatedExisting'] = true
            collection.update_one(document, cmd['update'])

            if cmd['new']
              rval['value'] = document
            end
          end
        elsif !cmd['remove'] && cmd['upsert']
          doc = collection.upsert(cmd['update'], cmd)
          rval['lastErrorObject']['upserted'] = doc['_id']
          if cmd['new']
            rval['value'] = doc
          end
        end

        reply_hash(rval)
      end

      command 'delete' do
        rval = {'n' => 0}

        cmd['deletes'].each_with_index do |delete, index|
          begin
            query = Query.new(delete['q'], collection.documents, delete)

            query.documents.each do |doc|
              collection.delete_one(doc['_id'])
              rval['n'] += 1
            end

          rescue HydroponicMongo::WriteError => e
            rval['writeErrors'] ||= []
            rval['writeErrors'].push({
              'index'  => index,
              'code'   => e.code,
              'errmsg' => e.messag
            })
          end
        end

        reply_hash(rval)
      end
    end
  end
end
