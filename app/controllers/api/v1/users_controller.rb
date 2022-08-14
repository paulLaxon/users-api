# frozen_string_literal: true

module Api
  module V1
    # users controller
    class Api::V1::UsersController < ApplicationController
      class MultipleUsersError < StandardError; end
      before_action :all_users

      def index
        find_users_by_query_params(request)
        raise(MultipleUsersError, 'Error: Too many users found.') if @users.size > 1 && !@return_multiple

        render json: @users
      rescue MultipleUsersError => e
        render plain: e.message
      end

      def create
        find_users_by_query_params(request)
        raise(MultipleUsersError, 'Error: User already exists.') if @user

        @user = User.new(user_params)
        @users << @user

        render json: @user
      rescue MultipleUsersError => e
        render plain: e.message
      end

      def destroy
        find_users_by_query_params(request)
        raise(MultipleUsersError, 'Error: Cannot delete, more than 1 user was found.') unless @users.size == 1

        @users&.delete(@user)
      rescue MultipleUsersError => e
        render plain: e.message
      end

      private

      def all_users
        @all_users = User.all
      end

      def find_users_by_query_params(request)
        conditions = {}
        request&.query_parameters&.each do |user_field, value|
          conditions[user_field.to_sym] = value.to_s
        end
        find_users(conditions)
      end

      def find_users(conditions)
        @return_multiple = to_bool(conditions.delete(:return_multiple))
        @users = @all_users&.select do |user|
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
        params.require(:user).permit!
      end
    end
  end
end
