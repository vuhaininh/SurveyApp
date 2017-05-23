# Helper methods defined here can be accessed in any controller or view in the application

module Svipk
  class Dashboard
    module SessionHelper
      def sign_in(user)
        cookie[:remembrance] = user.remember_token
        self.current_user = user
      end

      def signed_in?
        !current_user.nil?
      end

      def current_user=(user)
        @current_user = user
      end

      def current_user
        @current_user ||= Account[:remember_token => cookie[:remembrance]]
      end

      def is_admin
        return (current_user.role == "admin")
      end

      def sign_out
        self.current_user = nil
        cookies.delete :remembrance
      end

      def current_user?(user)
        user == current_user
      end

      def language
        if(@language_code)
          return Language.find(:language_code=>@language_code)
        else
          return Language.find(:language_code=>"en-GB")
        end
      end

      private
      def signed_in_user
        store_location
        redirect_to signin_url, notice: "Please sign in." unless signed_in?
      end

      #Redirect to location
      def redirect_back_or(default)
        redirect_to(session[:return_to] || default)
        session.delete(:return_to)
      end

      def store_location
        session[:return_to] = request.url
      end
    end

    helpers SessionHelper
  end
end
