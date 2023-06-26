module Mutations
  class SignOutUser < BaseMutation
    argument :token, String, required: true

    field :token, String, null: true
    field :errors, [String], null: true
    field :message, String, null: true

    def resolve(token)
      token = token[:token]

      if token.present? && valid_token?(token)
        Jwt::Blacklist::RevokeToken.call(token)
        { message: 'Logout successful', errors: [] }
      else
        { message: nil, errors: ['Invalid token'] }
      end
    end

    private

    def valid_token?(token)
      Jwt::Valid.call(token)
    end
  end
end
