require 'rails_helper'

RSpec.describe 'UserMutation', type: :request do
  describe 'createUser' do
    context 'when parameters are valid' do
      let(:valid_mutation) do
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
        post '/graphql', params: { query: valid_mutation }
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

    context 'when parameters are not valid' do
      let(:invalid_mutation) do
        <<~GQL
          mutation {
            createUser(input: {
              name: "Pedro"
              email: "pedro@example.com"
              password: ""
            }) {
              user {
                id
                name
                email
                role
              }
              errors
            }
          }
        GQL
      end

      it 'creates a new user' do
        post '/graphql', params: { query: invalid_mutation }
        json = JSON.parse(response.body)
        data = json['data']['createUser']['user']
        errors = json['data']['createUser']['errors']

        expect(data).to be_nil
        expect(errors).to eq(["Password can't be blank", "Password can't be blank",
                              'Password is too short (minimum is 6 characters)'])
      end
    end
  end
end
