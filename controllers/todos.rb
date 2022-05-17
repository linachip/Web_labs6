require_relative 'home'
require_relative '../models/todo'

class TodosController < HomeController
  def sync
    params["data"].each do |todo|
      record = Todo.find_by(id: todo["id"])
      if record
        record.assign_attributes(todo)
        record.save
      else
        Todo.create(todo)
      end
    end

    todos = Todo.where("user_id = #{params['user_id']}")
    render json: JSON.dump(todos.as_json)
  end
end
