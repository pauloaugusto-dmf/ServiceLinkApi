module Mutations
  class SignInUser < BaseMutation
    argument :credentials, Types::AuthProviderCredentialsInput, required: false

    field :user, Types::UserType, null: true
    field :token, String, null: true
    field :errors, [String], null: true

    def resolve(credentials: nil)
      return unless credentials

      user = User.find_by email: credentials[:email]

      if user&.authenticate(credentials[:password])
        token = Jwt::Encode.call(user)
        { user: user, token: token }
      else
        { errors: ['Invalid credentials'] }
      end
    end
  end
end
