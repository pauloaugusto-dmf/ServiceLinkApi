require 'rails_helper'

RSpec.describe 'UserQuery', type: :request do
  describe 'user' do
    let!(:user) { create(:user) }

    let(:query) do
      <<~GQL
        query {
          user(id: "#{user.id}") {
            id
            name
            email
          }
        }
      GQL
    end

    it 'returns the user' do
      post '/graphql', params: { query: query }
      json = JSON.parse(response.body)
      data = json['data']['user']

      expect(data['id']).to eq(user.id.to_s)
      expect(data['name']).to eq(user.name)
      expect(data['email']).to eq(user.email)
    end
  end
end
