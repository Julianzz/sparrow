class TodoSerializer < ActiveModel::Serializer
  attributes :id,:is_completed,:title
  def id
    object.id.to_s
  end
end
