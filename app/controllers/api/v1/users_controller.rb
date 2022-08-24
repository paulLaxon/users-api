# frozen_string_literal: true

module Api
  module V1
    # users controller
    class Api::V1::UsersController < ApplicationController
      class MultipleUsersError < StandardError; end
      before_action :fetch_all_users

      def index
        find_users_by_query_params(request)

        raise(MultipleUsersError, 'Error: Too many users found.') if @users.size > 1 && !@return_multiple
        raise(MultipleUsersError, 'Error: No user was found.') if @users.size.zero?

        render json: @users
      rescue MultipleUsersError => e
        render plain: e.message
      end

      def create
        @user = User.new(user_params)
        raise(MultipleUsersError, 'Error: User already exists.') if @all_users.include?(@user)

        @all_users << @user
        Rails.cache.write(:all_users, @all_users)

        render json: @all_users
      rescue MultipleUsersError => e
        render plain: e.message
      end

      def destroy
        find_users_by_query_params(request)
        raise(MultipleUsersError, 'Error: Cannot delete, more than 1 user was found.') if @users.size > 1
        raise(MultipleUsersError, 'Error: Cannot delete, no user was found.') if @users.size.zero?

        @all_users.delete(@user)
        Rails.cache.write(:all_users, @all_users)

        render json: @all_users
      rescue MultipleUsersError => e
        render plain: e.message
      end

      private

      def fetch_all_users
        users_cache_key = Rails.cache.instance_variable_get(:@data).keys
        puts("users cache: #{users_cache_key}")
        @all_users = Rails.cache.fetch(:all_users)
        puts("all users: #{@all_users}")
        return if @all_users.present?

        john1 = User.new(last_name: 'Doe', first_name: 'John', email: 'jdoe1@example.com', gov_id_number: '11111111', gov_id_type: 'licence')
        john2 = User.new(last_name: 'Doe', first_name: 'John', email: 'jdoe2@example.com', gov_id_number: '22222222', gov_id_type: 'licence')
        mary = User.new(last_name: 'Doe', first_name: 'Mary', email: 'mdoe@example.com', gov_id_number: '33333333', gov_id_type: 'licence')
        jill1 = User.new(last_name: 'Smith', first_name: 'Jill', email: 'jsmith@example.com', gov_id_number: '44444444', gov_id_type: 'licence')
        jill2 = User.new(last_name: 'Johnson', first_name: 'Jill', email: 'jjohnson@example.com', gov_id_number: '55555555', gov_id_type: 'licence')
        @all_users = [john1, john2, mary, jill1, jill2]
        Rails.cache.write(:all_users, @all_users)

        puts 'new users'
        @all_users.each { |u| puts u.to_s }
        puts
      end

      def find_users_by_query_params(request)
        conditions = {}
        request&.query_parameters&.each do |user_field, value|
          conditions[user_field.to_sym] = value.to_s
        end
        find_users(conditions)
      end

      def find_users(conditions)
        @users = []

        @return_multiple = to_bool(conditions.delete(:return_multiple))
        @users = @all_users.select do |user|
          conditions.each do |k, v|
            break if user[k] != v
          end
        end

        @user = @users[0] if @users.size == 1
      end

      def to_bool(str)
        return true if str == 'true'

        false
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :gov_id_number, :gov_id_type)
      end
    end
  end
end
