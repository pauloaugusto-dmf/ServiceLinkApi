module Mutations
  class CreateUser < BaseMutation
    argument :name, String, required: true
    argument :email, String, required: true
    argument :password, String, required: true
    argument :role, String, required: true
    argument :phone, String, required: false

    field :user, Types::UserType, null: true
    field :errors, [String], null: false

    def resolve(name:, email:, password:, role:, phone:)
      user = User.new(name: name, email: email, password: password, role: role, phone: phone)

      if user.save
        { user: user, errors: [] }
      else
        { user: nil, errors: user.errors.full_messages }
      end
    end
  end
end
