# frozen_string_literal: true

module Cocina
  module Models
    # A digital repository collection.  See http://sul-dlss.github.io/cocina-models/maps/Collection.json
    class Collection < Dry::Struct
      include Checkable

      TYPES = [
        Vocab.collection,
        Vocab.curated_collection,
        Vocab.user_collection,
        Vocab.exhibit,
        Vocab.series
      ].freeze

      # Subschema for access concerns
      class Access < Dry::Struct
        def self.from_dynamic(_dyn)
          params = {}
          Access.new(params)
        end
      end

      # Subschema for administrative concerns
      class Administrative < Dry::Struct
        attribute :releaseTags, Types::Strict::Array.of(ReleaseTag).default([].freeze)
        # Allowing hasAdminPolicy to be omittable for now (until rolled out to consumers),
        # but I think it's actually required for every DRO
        attribute :hasAdminPolicy, Types::Coercible::String.optional.default(nil)

        def self.from_dynamic(dyn)
          params = {}
          params[:releaseTags] = dyn['releaseTags'].map { |rt| ReleaseTag.from_dynamic(rt) } if dyn['releaseTags']
          params[:hasAdminPolicy] = dyn['hasAdminPolicy']
          Administrative.new(params)
        end
      end

      # Identification sub-schema for the Collection
      class Identification < Dry::Struct
        attribute :catalogLinks, Types::Strict::Array.of(CatalogLink).meta(omittable: true)

        def self.from_dynamic(dyn)
          params = {}
          if dyn['catalogLinks']
            params[:catalogLinks] = dyn['catalogLinks']
                                    .map { |link| CatalogLink.from_dynamic(link) }
          end
          params
        end
      end

      class Structural < Dry::Struct
      end

      attribute :externalIdentifier, Types::Strict::String
      attribute :type, Types::String.enum(*TYPES)
      attribute :label, Types::Strict::String
      attribute :version, Types::Coercible::Integer
      attribute(:access, Access.default { Access.new })
      attribute(:administrative, Administrative.default { Administrative.new })
      # Allowing description to be omittable for now (until rolled out to consumers),
      # but I think it's actually required for every DRO
      attribute :description, Description.optional.default(nil)
      attribute(:identification, Identification.default { Identification.new })
      attribute(:structural, Structural.default { Structural.new })

      def self.from_dynamic(dyn)
        CollectionBuilder.build(self, dyn)
      end

      def self.from_json(json)
        from_dynamic(JSON.parse(json))
      end
    end
  end
end
