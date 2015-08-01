class CategorySerializer < ActiveModel::Serializer
  attributes :id
  attribute :name, key: :title
  attribute :slug, key: :name
end
