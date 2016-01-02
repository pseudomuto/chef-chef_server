override["chef-server"]["api_fqdn"] = "chef.sweeper.io"
override["chef-server"]["topology"] = "standalone"
override["chef-server"]["version"]  = "12.3.1"

override["chef-server"]["configuration"] = <<-EOF
nginx["non_ssl_port"]      = false
nginx["ssl_company_name"]  = "sweeper.io"
nginx["ssl_email_address"] = "developers@sweeper.io"
nginx["ssl_locality_name"] = "Ottawa"
nginx["ssl_state_name"]    = "ON"
nginx["ssl_country_name"]  = "CA"

notification_email "developers@sweeper.io"
EOF
