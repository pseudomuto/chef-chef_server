require "bundler/setup"
require "chef"

SECRET_FILE        = "./test/integration/encrypted_data_bag_secret".freeze
INPUT_PATH_FORMAT  = "./test/integration/data_bags/%s/%s.plaintext.json".freeze
OUTPUT_PATH_FORMAT = "./test/integration/data_bags/%s/%s.json".freeze

def raw_bag_item(args)
  path = format(INPUT_PATH_FORMAT, *args.values_at(:bag, :item))
  hash = JSON.parse(File.read(path))

  Chef::DataBagItem.from_hash(hash)
end

desc "encrypts a data bag item for integration tests"
task :encrypt_data_bag, [:bag, :item] do |_, args|
  data_bag_item   = raw_bag_item(args)
  data_bag_secret = Chef::EncryptedDataBagItem.load_secret(SECRET_FILE)
  encrypted_item  = Chef::EncryptedDataBagItem.encrypt_data_bag_item(data_bag_item, data_bag_secret)

  pretty_json = JSON.pretty_generate(encrypted_item.to_hash)
  output_path = format(OUTPUT_PATH_FORMAT, *args.values_at(:bag, :item))
  File.open(output_path, "w") { |file| file.write(pretty_json) }

  puts format("encrypted test data bag: %s", output_path)
end
