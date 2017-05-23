#The data table presented by this class will stored all files which has been uploaded to the system
class Upload < Sequel::Model
   mount_uploader :file, Uploader
   many_to_one :category

end
