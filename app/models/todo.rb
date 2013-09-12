class Todo
  include Mongoid::Document
  field :title, type: String
  field :is_completed, type: Boolean
  
  belongs_to :user
  
end
