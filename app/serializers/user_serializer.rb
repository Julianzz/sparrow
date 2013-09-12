class UserSerializer < ActiveModel::Serializer
  attributes :id,:email
  def id
    object.id.to_s
  end
  
  def email
    return "hello"
  end
end
