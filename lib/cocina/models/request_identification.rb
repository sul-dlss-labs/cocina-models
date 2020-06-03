# frozen_string_literal: true

module Cocina
  module Models
    class RequestIdentification < Struct
      # example: sul:PC0170_s3_Fiesta_Bowl_2012-01-02_210609_2026
      attribute :sourceId, Types::Strict::String
      attribute :catalogLinks, Types::Strict::Array.of(CatalogLink).meta(omittable: true)
    end
  end
end