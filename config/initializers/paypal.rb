PayPal::SDK.load("config/paypal.yml", Rails.env)
PayPal::SDK.logger = Rails.logger

# include PayPal::SDK::OpenIDConnect

# Generate authorize URL to Get Authorize code
# puts Tokeninfo.authorize_url( :scope => "openid profile" )

# Create tokeninfo by using Authorize Code from redirect_uri
# tokeninfo = Tokeninfo.create("Replace with Authorize Code received on redirect_uri")

# Refresh tokeninfo object
# tokeninfo.refresh

# Create tokeninfo by using refresh token
# tokeninfo = Tokeninfo.refresh("Replace with refresh_token")

# Get Userinfo
# userinfo = tokeninfo.userinfo

# Get Userinfo by using access token
# userinfo = Userinfo.get("Replace with access_token")

# Get logout url
# logout_url = tokeninfo.logout_url