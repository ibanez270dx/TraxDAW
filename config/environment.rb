# Load the rails application.
require File.expand_path('../application', __FILE__)

# Initialize the rails application.
AudioTrax::Application.initialize!

# Load Amazon S3 Config
path = File.join(Rails.root, 'config/amazon.yml')
AMAZON = YAML.load(ERB.new(File.read(path)).result)[Rails.env].symbolize_keys
