require 'rails_helper'

RSpec.describe 'SessionsMutation', type: :request do
  describe 'sign_in' do
    let!(:user) { create :user, name: 'Fulano', email: 'fulano@example.com', password: '123456' }
    let(:valid_mutation) do
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
        post '/graphql', params: { query: valid_mutation }
        json = JSON.parse(response.body)
        data = json['data']['signInUser']['user']
        token = json['data']['signInUser']['token']

        expect(data['name']).to eq('Fulano')
        expect(data['email']).to eq('fulano@example.com')
        expect(token).not_to be_nil
      end
    end

    let(:invalid_mutation) do
      <<~GQL
           mutation {
             signInUser(
        	input: {
        		credentials: {
        			email: "fulano@example.com"
              			password: "invalid_password"
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

    context 'when credentials are not valid' do
      it 'must not return a JWT token' do
        post '/graphql', params: { query: invalid_mutation }
        json = JSON.parse(response.body)
        data = json['data']['signInUser']['user']
        token = json['data']['signInUser']['token']
        errors = json['data']['signInUser']['errors']

        expect(data).to be_nil
        expect(token).to be_nil
        expect(errors).to eq(['Invalid credentials'])
      end
    end
  end

  describe 'sign_out' do
    # TODO: Check why test is not working in github actions
    let!(:user) { create :user, name: 'Fulano', email: 'fulano@example.com', password: '123456' }
    let(:token) { Jwt::Encode.call(user) }
    let(:valid_mutation) do
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
      xit 'revokes the token and returns a success message' do
        post '/graphql', params: { query: valid_mutation }
        json = JSON.parse(response.body)
        data = json['data']['signOutUser']['message']

        expect(data).to eq('Logout successful')
      end
    end

    let(:invalid_mutation) do
      <<~GQL
        mutation {
        	signOutUser(
        		input:
        			{
        				token: "invalid_token"
        			}
        		)
        			{
        			message
        			errors
        	}
        }
      GQL
    end

    context 'when token are not valid' do
      xit 'returns a error message' do
        post '/graphql', params: { query: invalid_mutation }
        json = JSON.parse(response.body)
        data = json['data']['signOutUser']['message']
        errors = json['data']['signOutUser']['errors']

        expect(data).to be_nil
        expect(errors).to eq(['Invalid token'])
      end
    end
  end
end
