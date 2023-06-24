require 'rails_helper'

RSpec.describe 'UserMutation', type: :request do
  describe 'createUser' do
    let(:mutation) do
      <<~GQL
        mutation {
          createUser(input: {
            name: "Pedro"
            email: "pedro@example.com"
            password: "password"
          }) {
            user {
              id
              name
              email
              role
            }
          }
        }
      GQL
    end

    it 'creates a new user' do
      post '/graphql', params: { query: mutation }
      json = JSON.parse(response.body)
      data = json['data']['createUser']['user']

      expect(data['name']).to eq('Pedro')
      expect(data['email']).to eq('pedro@example.com')
      expect(data['role']).to eq(0)

      user = User.last
      expect(user.name).to eq('Pedro')
      expect(user.email).to eq('pedro@example.com')
      expect(user.role).to eq('client')
    end
  end
end
