require 'rails_helper'

RSpec.describe 'SessionsMutation', type: :request do
  describe 'sign_in' do
    let!(:user) { create :user, name: 'Fulano', email: 'fulano@example.com', password: '123456' }
    let(:mutation) do
      <<~GQL
           mutation {
             signInUser(
        	input: {
        		credentials: {
        			email: "fulano@example.com"
              			password: "123456"
        		}
             })
        {
        	token
               user {
                 name
                 email
               }
        	errors
             }
           }
      GQL
    end

    context 'when credentials is valid' do
      it 'returns a JWT token' do
        post '/graphql', params: { query: mutation }
        json = JSON.parse(response.body)
        data = json['data']['signInUser']['user']
        token = json['data']['signInUser']['token']

        expect(data['name']).to eq('Fulano')
        expect(data['email']).to eq('fulano@example.com')
        expect(token).not_to be_nil
      end
    end
  end

  describe 'sign_out' do
    let!(:user) { create :user, name: 'Fulano', email: 'fulano@example.com', password: '123456' }
    let(:token) { Jwt::Encode.call(user) }
    let(:mutation) do
      <<~GQL
        mutation {
        	signOutUser(
        		input:
        			{
        				token: "eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0fQ._-YSgIYxBWZyw38e1iUUtKjYuDxCRWGMhRHLMB0lFYA"
        			}
        		)
        			{
        			message
        			errors
        	}
        }
      GQL
    end

    context 'when token is valid' do
      it 'revokes the token and returns a success message' do
        post '/graphql', params: { query: mutation }
        json = JSON.parse(response.body)
        data = json['data']['signOutUser']['message']

        expect(data).to eq('Logout successful')
      end
    end
  end
end
