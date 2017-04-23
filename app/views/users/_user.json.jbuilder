json.extract! user, :id, :latitude, :longitude, :city, :idecko, :state, :isocode, :created_at, :updated_at
json.url user_url(user, format: :json)