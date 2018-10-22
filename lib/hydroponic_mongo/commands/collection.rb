# frozen_string_literal: true

module HydroponicMongo
  module Commands
    module Collection
      def collection_insert(cmd)
        reply_hash({'n' => collection.insert(cmd['documents'])})
      end

      def collection_find(cmd)
        cursor("#{database.name}.#{collection.name}",
               collection.find(cmd['filter'], cmd))
      end

      def collection_count(cmd)
        reply_hash({
          'n' => collection.find(cmd['query'], cmd).count
        })
      end

      def collection_update(cmd)
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

      def collection_findAndModify(cmd)
        rval = {
          'value' => nil,
          'lastErrorObject' => {
            'updatedExisting' => false,
            'upserted' => {},
          }
        }

        query_options = {}
        if cmd['sort']
          query_options['sort'] = cmd['sort']
        end

        document = collection.find(cmd['query'], query_options).first

        if document
          rval['value'] = document

          if cmd['remove']
            collection.delete_one(document['_id'])
          else # update
            if !cmd['new']
              rval['value'] = document.deep_dup
            end
            rval['lastErrorObject']['updatedExisting'] = true
            collection.update_one(document, cmd['update'])
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

      def collection_delete(cmd)
        rval = {'n' => 0}
        n = 0

        cmd['deletes'].each_with_index do |delete, index|
          begin
            n = collection.delete(delete['q'], delete)
            rval['n'] += n
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
