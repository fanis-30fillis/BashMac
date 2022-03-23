#!/bin/bash


# declares the arrays with popular OUIs
declare -a intel_ouis
declare -a dell_ouis
declare -a alpha_ouis
declare -a tplink_ouis

declare -a vendors
vendors=("intel" "tplink" "alpha" "dell")
# declares some intel ouis
intel_ouis=(3C:9C:0F FC:44:82 D8:F8:83 E8:84:A5 18:26:49 DC:41:A9
	44:AF:28 FC:B3:BC 18:CC:18 C0:3C:59 84:1B:77 BC:17:B8 E0:D4:64
	8C:8D:28 90:CC:DF 08:5B:D6 B4:0E:DE E0:2B:E9 C8:B2:9B 2C:DB:07
	98:8D:46 68:54:5A 70:9C:D1 68:3E:26 8C:55:4A 40:1C:83 38:FC:98
	F8:5E:A0 50:2F:9B AC:67:5D B0:A4:60 B0:7D:64 00:42:38 94:E6:F7
	4C:1D:96 50:E0:85 DC:71:96 B8:08:CF 68:17:29 D0:AB:D5 D4:3B:04
	04:EA:56 D0:C6:37 98:3B:8F 1C:1B:B5 DC:8B:28)

# declares some alpha ouis
alpha_ouis=(00:0F:A3 00:1D:6A D0:AE:EC 00:18:02 54:2A:A2 88:6A:E3
	0C:83:CC 5C:33:8E)

# declares some dell ouis
dell_ouis=(CC:48:3A 30:D0:42 70:B5:E8 B8:CB:29 24:71:52 8C:47:BE
	98:E7:43 C8:F7:50 6C:2B:59 DC:F4:01)

# declares some tplink ouis
tplink_ouis=(60:32:B1 C0:C9:E3 F8:8C:21 80:EA:07 E4:C3:2A 90:9A:4A
	84:D8:1B 3C:84:6A D0:37:45 60:3A:7C 54:A7:03 B0:BE:76 34:E8:94
	AC:84:C6 94:D9:B3 B0:95:8E C0:25:E9 24:69:68 80:89:17 00:27:19
	40:16:9F F4:EC:38 14:CF:92 20:DC:E6 14:CC:20 90:F6:52 54:C8:0F
	E4:D3:32 C4:E9:84 28:2C:B2 E8:DE:27 BC:D1:77 D8:07:B6 64:6E:97
	98:DA:C4 CC:08:FB D4:6E:0E 00:14:78 30:FC:68 DC:00:77)

