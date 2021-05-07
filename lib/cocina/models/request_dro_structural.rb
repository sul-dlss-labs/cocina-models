# frozen_string_literal: true

module Cocina
  module Models
    class RequestDROStructural < Struct
      attribute :contains, Types::Strict::Array.of(RequestFileSet).meta(omittable: true)
      attribute :hasMemberOrders, Types::Strict::Array.of(Sequence).meta(omittable: true)
      attribute :isMemberOf, Types::Strict::Array.of(Druid).meta(omittable: true)
    end
  end
end
