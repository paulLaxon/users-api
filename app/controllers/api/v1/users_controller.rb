# frozen_string_literal: true

module Api
  module V1
    # users controller
    class Api::V1::UsersController < ApplicationController
      class FindUsersError < StandardError; end
      before_action :fetch_all_users

      def index
        find_users_by_query_params(request)

        raise(FindUsersError, 'Error: Too many users found.') if @users.size > 1 && !@return_multiple
        raise(FindUsersError, 'Error: No user was found.') if @users.size.zero?

        render json: @users
      rescue FindUsersError => e
        render plain: e.message
      end

      def create
        @user = User.new(user_params)
        raise(FindUsersError, 'Error: User already exists.') if @all_users.include?(@user)

        @all_users << @user
        Rails.cache.write(:all_users, @all_users)

        render json: @all_users
      rescue FindUsersError => e
        render plain: e.message
      end

      def destroy
        find_users_by_query_params(request)
        raise(FindUsersError, 'Error: Cannot delete, more than 1 user was found.') if @users.size > 1
        raise(FindUsersError, 'Error: Cannot delete, no user was found.') if @users.size.zero?

        @all_users.delete(@user)
        Rails.cache.write(:all_users, @all_users)

        render json: @all_users
      rescue FindUsersError => e
        render plain: e.message
      end

      private

      def fetch_all_users
        @all_users = Rails.cache.fetch(:all_users)
        @all_users = [] if @all_users.blank?
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
