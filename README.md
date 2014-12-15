## Overview

This is a Diameter test suite for exercising the 3GPP Cx and Sh interfaces. It was originally developed to reproduce bugs in the OpenIMSCore HSS (a.k.a. FHoSS) and confirm that they are fixed. However, it exercises standard, well-defined interfaces over an open protocol, so there's no reason it shouldn't work with other HSSes. However, it hasn't been tested with other HSSes and may rely on quirks of FHoSS implementation.

## Configuration

All configuration of this test suite happens through environment variables set on the command line, e.g.:

`HSS_IP=1.2.3.4 ruby tests/basic_flow.rb`

* HSS_IP - the IP address of the HSS to test
* HSS_PORT - the port of the HSS to test (defaults to 3868)
* HSS_IDENTITY - the Diameter identity for the HSS (defaults to "hss.open-ims.test" to match default FHoSS configuration)
* HSS_REALM - the Diameter realm for the HSS (defaults to "open-ims.test" to match default FHoSS configuration)
* ORIGIN_HOST - the Diameter identity for this test suite (defaults to "presence.open-ims.test" to match the default AS configured in FHoSS)
* ORIGIN_REALM - the Diameter realm for this test suite (defaults to "test-realm")
* IMPU - the public identity to specify on messages (defaults to "sip:alice@open-ims.test" to match default FHoSS configuration)
* IMPI - the private identity to specify on messages (defaults to "alice@open-ims.test" to match default FHoSS configuration)

## Basic flow

`ruby tests/basic_flow.rb`

This exercises the basic functions of the Cx interface:
* sends a SAR specifying TIMEOUT_DEREGISTRATION, to put the user back into a clean state
* sends a UAR (which the I-CSCF would send on a REGISTER)
* sends a MAR (which the S-CSCF would send on a REGISTER)
* sends a SAR specifying REGISTRATION (which the S-CSCF would send on a REGISTER)
* sends a LIR (which the I-CSCF would send on an INVITE)

It checks that each response is received, has a succesful result-code, and contains the expected AVPs.

It also prints out the User-Data XML, so this script can be used to confirm that subscriber profile changes have correctly taken effect.

## Authentication failure flow

`ruby tests/auth_failure.rb`

This simulates a failed authentication. It was originally added to reproduce an OpenIMSCore HSS bug where Location-Information-Answers were malformed after a failed authentication.

It:

* sends a SAR specifying TIMEOUT_DEREGISTRATION, to put the user back into a clean state
* sends a UAR (which the I-CSCF would send on a REGISTER)
* sends a MAR (which the S-CSCF would send on a REGISTER)
* sends a SAR specifying AUTHENTICATION_TIMEOUT (which the S-CSCF would send if the credentials were wrong)
* sends a LIR (which the I-CSCF would send on an INVITE)

It then checks that the LIR is complete and not malformed.

## Transparent data storage

`ruby tests/sh_put.rb`

This exercises the HSS's Sh interface. It was originally added to track down a bug where data structured as XML was silently dropped by the parser.

Note that this test requires some configuration changes on the HSS - specifically, this test suite's Origin-Host must be recognised as an AS and it must have permissions to access Repository-Data with a UDR and a PUR.

One test:
* sends a UDR to discover the sequence number
* sends a PUR to store a simple (non-XML) string in the HSS
* sends a UDR which should retrieve that string

The other test:
* sends a UDR to discover the sequence number
* sends a PUR to store an XML element in the HSS
* sends a UDR which should retrieve that string
