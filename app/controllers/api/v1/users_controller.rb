# frozen_string_literal: true

module Api
  module V1
    # users controller
    class Api::V1::UsersController < ApplicationController
      class CannotDeleteError < StandardError; end

      def index
        find_users(request)
        render json: @users
      end

      def create
        @user = User.new(user_params)
        @user&.save
        render json: @user
      end

      def destroy
        find_users(request)

        raise(CannotDeleteError, 'Cannot delete, more than 1 user returned.') unless @users.size == 1

        @user&.destroy
      rescue CannotDeleteError => e
        render plain: e.message
      end

      private

      def find_users(request)
        conditions = {}
        request&.query_parameters&.each do |user_field, value|
          conditions[user_field.to_sym] = value.to_s
        end
        @users = User.where(conditions)
        @user = @users[0] if @users.size == 1
      end

      def user_params
        params.require(:user).permit!
      end
    end
  end
end
