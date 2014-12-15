require 'minitest/autorun'
require 'diameter/stack'
require_relative "./get_config_from_env.rb"

include Diameter

AVP.define("Visited-Network-Identifier", 600, :OctetString, 10415)
AVP.define("User-Data-Already-Available", 624, :Unsigned32, 10415)
AVP.define("Server-Assignment-Type", 614, :Unsigned32, 10415)
AVP.define("User-Data", 606, :OctetString, 10415)
AVP.define("Sh-User-Data", 702, :OctetString, 10415)
AVP.define("Service-Indication", 704, :OctetString, 10415)
AVP.define("User-Identity", 700, :Grouped, 10415)
AVP.define("Data-Reference", 703, :Unsigned32, 10415)
AVP.define("Experimental-Result", 297, :Grouped, 0)
AVP.define("Experimental-Result-Code", 298, :Unsigned32, 0)

def wrap_sh_data(string, service_indication, seqn)
  "<?xml version=\"1.0\" encoding=\"UTF-8\"?><Sh-Data xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"ShDataType.xsd\"><RepositoryData><ServiceIndication>#{service_indication}</ServiceIndication><SequenceNumber>#{seqn}</SequenceNumber><ServiceData><Data>#{string}</Data></ServiceData></RepositoryData></Sh-Data>"
end

describe "OpenIMSCore HSS" do
  before do
    @client_stack = Stack.new(ORIGIN_HOST, ORIGIN_REALM)
    @client_stack.add_handler(16777217, auth: true, vendor: 10415) { nil }
    @client_stack.start
    peer = @client_stack.connect_to_peer(HSS_URI, HSS_ID, HSS_REALM)
    peer.wait_for_state_change :UP
  end

  after do
    @client_stack.shutdown
  end
  
  it "should accept plain Sh data and allow it to be retrieved" do
    udr_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Service-Indication", "test"),
               ]
    udr = Message.new(command_code: 306, app_id: 16777217, avps: udr_avps)
    uda = @client_stack.send_request(udr).value(1)

    data = uda ? uda.avp('Sh-User-Data') : nil
    seq = if data.nil?
            0
          elsif /<SequenceNumber>(\d+)<\/SequenceNumber>/.match(data.octet_string)
                 /<SequenceNumber>(\d+)<\/SequenceNumber>/.match(data.octet_string)[1].to_i + 1
          else
            0
          end
    
    pur_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Sh-User-Data", wrap_sh_data("shibboleth", "test", seq)),
               ]
    pur = Message.new(command_code: 307, app_id: 16777217, avps: pur_avps)
    pua = @client_stack.send_request(pur).value
    pua['Result-Code'][0].uint32.must_equal 2001

    udr_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Service-Indication", "test"),
               ]
    udr = Message.new(command_code: 306, app_id: 16777217, avps: udr_avps)
    uda = @client_stack.send_request(udr).value

    uda['Result-Code'][0].uint32.must_equal 2001
    puts uda.avp('Sh-User-Data')

  end

  it "should accept Sh data in XML format and allow it to be retrieved" do
    udr_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Service-Indication", "test2"),
               ]
    udr = Message.new(command_code: 306, app_id: 16777217, avps: udr_avps)
    uda = @client_stack.send_request(udr).value(1)

    data = uda ? uda.avp('Sh-User-Data') : nil
    seq = if data.nil?
            0
          elsif /<SequenceNumber>(\d+)<\/SequenceNumber>/.match(data.octet_string)
                 /<SequenceNumber>(\d+)<\/SequenceNumber>/.match(data.octet_string)[1].to_i + 1
          else
            0
          end
    
    pur_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Sh-User-Data", wrap_sh_data("<hello attr=\"six\">world</hello><test/>", "test2", seq)),
               ]
    pur = Message.new(command_code: 307, app_id: 16777217, avps: pur_avps)
    pua = @client_stack.send_request(pur).value
    pua['Result-Code'][0].uint32.must_equal 2001

    udr_avps = [AVP.create("Session-Id", "one"),
                AVP.create("Vendor-Specific-Application-Id",
                           [AVP.create("Vendor-Id", 10415),
                            AVP.create("Auth-Application-Id", 16777217)]),
                AVP.create("Auth-Session-State", 0),
                AVP.create("Destination-Host", HSS_ID),
                AVP.create("Destination-Realm", HSS_REALM),
                AVP.create("User-Name", IMPI),
                AVP.create("User-Identity", [AVP.create("Public-Identity", IMPU)]),
                AVP.create("Data-Reference", 0),
                AVP.create("Service-Indication", "test2"),
               ]
    udr = Message.new(command_code: 306, app_id: 16777217, avps: udr_avps)
    uda = @client_stack.send_request(udr).value

    uda['Result-Code'][0].uint32.must_equal 2001
    puts uda.avp('Sh-User-Data').octet_string
  end
end
