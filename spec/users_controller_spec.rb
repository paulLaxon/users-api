# frozen_string_literal: true

Rspec.describe 'Users', type: :request do
  context 'GET /index' do
    before do
      FactoryBot.create_list(:user1, :user2, :user3)
    end
    it 'returns list of users' do
      get '/api/v1/users?last_name=Doe'
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  context 'POST /create', type: :request do
    it 'creates a new user' do

    end
  end

  context 'DELETE /destroy', type: :request do
    it 'deletes a single user' do

    end

    it 'returns an error message if more than one user is returned' do

    end
  end
end
