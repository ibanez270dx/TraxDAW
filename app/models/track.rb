class Track < ActiveRecord::Base

  has_attached_file :photo,
  storage: :s3,
  bucket: AMAZON[:bucket],
  s3_credentials: {
    access_key_id: AMAZON[:access_key_id],
    secret_access_key: AMAZON[:secret_access_key]
  }

end
