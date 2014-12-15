HSS_IP = ENV['HSS_IP'] || fail("HSS_IP must be specified!")
HSS_PORT = ENV['HSS_PORT'] || 3868
HSS_URI = "aaa://#{HSS_IP}:#{HSS_PORT}"
HSS_ID = ENV['HSS_IDENTITY'] || "hss.open-ims.test"
HSS_REALM = ENV['HSS_REALM'] || "open-ims.test"

ORIGIN_HOST = ENV['ORIGIN_HOST'] || "presence.open-ims.test"
ORIGIN_REALM = ENV['ORIGIN_REALM'] || "test-realm"

IMPU = ENV['IMPU'] || "sip:alice@open-ims.test"
IMPI = ENV['IMPI'] || "alice@open-ims.test"

