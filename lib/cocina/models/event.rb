# frozen_string_literal: true

module Cocina
  module Models
    class Event < Struct
      attribute :structuredValue, Types::Strict::Array.of(DescriptiveBasicValue).meta(omittable: true)
      # Description of the event (creation, publication, etc.).
      attribute :type, Types::Strict::String.meta(omittable: true)
      attribute :date, Types::Strict::Array.of(DescriptiveValue).meta(omittable: true)
      attribute :contributor, Types::Strict::Array.of(Contributor).meta(omittable: true)
      attribute :location, Types::Strict::Array.of(DescriptiveValue).meta(omittable: true)
      attribute :note, Types::Strict::Array.of(DescriptiveValue).meta(omittable: true)
    end
  end
end
