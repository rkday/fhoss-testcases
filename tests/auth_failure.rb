require 'minitest/autorun'
require 'diameter/stack'
require_relative "./get_config_from_env.rb"

include Diameter

AVP.define("Visited-Network-Identifier", 600, :OctetString, 10415)
AVP.define("User-Data-Already-Available", 624, :Unsigned32, 10415)
AVP.define("Server-Assignment-Type", 614, :Unsigned32, 10415)
AVP.define("User-Data", 606, :OctetString, 10415)
AVP.define("Experimental-Result", 297, :Grouped, 0)
AVP.define("Experimental-Result-Code", 298, :Unsigned32, 0)

describe "OpenIMSCore HSS" do
  it "should still allow LIRs after an authentication failure" do
    client_stack = Stack.new(ORIGIN_HOST, ORIGIN_REALM)
    client_stack.add_handler(16777216, auth: true, vendor: 10415) { nil }
    client_stack.start
    peer = client_stack.connect_to_peer(HSS_URI, HSS_ID, HSS_REALM)
    peer.wait_for_state_change :UP

    # Unregister the user to ensure a clean state
    sar_avps = [AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777216)]),
                AVP.create("Session-Id", "one"),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("Auth-Session-State", 0),
                AVP.create("User-Name", IMPI),
                AVP.create("Public-Identity", IMPU),
                AVP.create("Server-Name", "sip:scscf@open-ims.test"),
                AVP.create("User-Data-Already-Available", 0),
                AVP.create("Server-Assignment-Type", 5),
               ]
    sar = Message.new(command_code: 301, app_id: 16777216, avps: sar_avps)
    saa = client_stack.send_request(sar).value

    saa['Result-Code'][0].uint32.must_equal 2001

    
    uar_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777216)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("Public-Identity", IMPU),
                AVP.create("Visited-Network-Identifier", "open-ims.test"),
               ]
    uar = Message.new(command_code: 300, app_id: 16777216, avps: uar_avps)
    uaa = client_stack.send_request(uar).value

    required_avps = ["Session-Id", "Vendor-Specific-Application-Id", "Auth-Session-State", "Origin-Host", "Origin-Realm"]

    required_avps.each do |name|
      uaa.avp(name).wont_be_nil
    end
    
    mar_avps = [AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777216)]),
                AVP.create("Session-Id", "one"),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("Auth-Session-State", 0),
                AVP.create("User-Name", IMPI),
                AVP.create("Public-Identity", IMPU),
                AVP.create("Server-Name", "sip:scscf@open-ims.test"),
                AVP.create("SIP-Number-Auth-Items", 1),
                AVP.create("SIP-Auth-Data-Item",
                           [AVP.create("SIP-Authentication-Scheme", "Unknown")]),
               ]
    mar = Message.new(command_code: 303, app_id: 16777216, avps: mar_avps)
    maa = client_stack.send_request(mar).value

    maa['Result-Code'][0].uint32.must_equal 2001

    required_avps = ["Session-Id", "Vendor-Specific-Application-Id", "Auth-Session-State", "Origin-Host", "Origin-Realm", "SIP-Auth-Data-Item"]

    required_avps.each do |name|
      maa.avp(name).wont_be_nil
    end


    sar_avps = [AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777216)]),
                AVP.create("Session-Id", "one"),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("Auth-Session-State", 0),
                AVP.create("User-Name", IMPI),
                AVP.create("Public-Identity", IMPU),
                AVP.create("Server-Name", "sip:scscf@open-ims.test"),
                AVP.create("User-Data-Already-Available", 0),
                AVP.create("Server-Assignment-Type", 9),
               ]
    sar = Message.new(command_code: 301, app_id: 16777216, avps: sar_avps)
    saa = client_stack.send_request(sar).value

    saa['Result-Code'][0].uint32.must_equal 2001

    required_avps = ["Session-Id", "Vendor-Specific-Application-Id", "Auth-Session-State", "Origin-Host", "Origin-Realm"]

    required_avps.each do |name|
      saa.avp(name).wont_be_nil("Expected a #{name} AVP but none was found")
    end

    lir_avps = [AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777216)]),
                AVP.create("Session-Id", "one"),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Public-Identity", IMPU),
               ]
    lir = Message.new(command_code: 302, app_id: 16777216, avps: lir_avps)
    lia = client_stack.send_request(lir).value

    required_avps = ["Session-Id", "Vendor-Specific-Application-Id", "Auth-Session-State", "Origin-Host", "Origin-Realm", "Result-Code"]

    required_avps.each do |name|
      lia.avp(name).wont_be_nil("Expected a #{name} AVP but none was found")
    end

    lia['Result-Code'][0].uint32.must_equal 2001
    
  end
end
