unit EvilWorks.Api.WinPCap.Bpf;

// Translated from v1.4.2.11

interface

uses
	WinApi.Windows,
	EvilWorks.Api.Winsock2; // you can remove this and use WinApi.Winsock instead. Required for u_int, etc

type
	bpf_int32    = integer;
	bpf_u_int32  = u_int;
	pbpf_u_int32 = ^bpf_u_int32;

const
	BPF_MAXBUFSIZE = $8000;
	BPF_MINBUFSIZE = 32;

	// Current version number of filter architecture.
	BPF_MAJOR_VERSION = 1;
	BPF_MINOR_VERSION = 1;

	//
	//  Alignment macros.  BPF_WORDALIGN rounds up to the next
	//  even multiple of BPF_ALIGNMENT.
	//
	BPF_ALIGNMENT = sizeof(bpf_int32);

	//
	//  Number of scratch memory words (for BPF_LD|BPF_MEM and BPF_ST).
	//
	BPF_MEMWORDS = 16;

function BPF_WORDALIGN(x: integer): integer;

type

	//
	//  The instruction data structure.
	//
	pbpf_insn = ^bpf_insn;

	bpf_insn = record
		code: u_short;
		jt: u_char;
		jf: u_char;
		k: bpf_u_int32;
	end;

	//
	//  Structure for "pcap_compile()", "pcap_setfilter()", etc..
	//

	{ bpf_program }
	pbpf_program = ^bpf_program;

	bpf_program = record
		bf_len: u_int;
		bf_insns: pbpf_insn;
	end;

	//
	//  Struct return by BIOCVERSION.  This represents the version number of
	//  the filter language described by the instruction encodings below.
	//  bpf understands a program iff kernel_major == filter_major &&
	//  kernel_minor >= filter_minor, that is, if the value returned by the
	//  running kernel has the same major number and a minor number equal
	//  equal to or less than the filter being downloaded.  Otherwise, the
	//  results are undefined, meaning an error may be returned or packets
	//  may be accepted haphazardly.
	//  It has nothing to do with the source code version.
	//
	{ bpf_version }
	pbpf_version = ^bpf_version;

	bpf_version = record
		bv_major: u_short;
		bv_minor: u_short;
	end;

const

	//
	//  Data-link level type codes.
	//
	//  Do//NOT* add new values to this list without asking
	//  "tcpdump-workers@lists.tcpdump.org" for a value.  Otherwise, you run
	//  the risk of using a value that's already being used for some other
	//  purpose, and of having tools that read libpcap-format captures not
	//  being able to handle captures with your new DLT_ value, with no hope
	//  that they will ever be changed to do so (as that would destroy their
	//  ability to read captures using that value for that other purpose).
	//

	//
	//  These are the types that are the same on all platforms, and that
	//  have been defined by <net/bpf.h> for ages.
	//
	DLT_NULL    = 0;  // BSD loopback encapsulation//
	DLT_EN10MB  = 1;  // Ethernet (10Mb)//
	DLT_EN3MB   = 2;  // Experimental Ethernet (3Mb)//
	DLT_AX25    = 3;  // Amateur Radio AX.25//
	DLT_PRONET  = 4;  // Proteon ProNET Token Ring//
	DLT_CHAOS   = 5;  // Chaos//
	DLT_IEEE802 = 6;  // 802.5 Token Ring//
	DLT_ARCNET  = 7;  // ARCNET, with BSD-style header//
	DLT_SLIP    = 8;  // Serial Line IP//
	DLT_PPP     = 9;  // Point-to-point Protocol//
	DLT_FDDI    = 10; // FDDI//

	//
	//  These are types that are different on some platforms, and that
	//  have been defined by <net/bpf.h> for ages.  We use #ifdefs to
	//  detect the BSDs that define them differently from the traditional
	//  libpcap <net/bpf.h>
	//
	//  XXX - DLT_ATM_RFC1483 is 13 in BSD/OS, and DLT_RAW is 14 in BSD/OS,
	//  but I don't know what the right #define is for BSD/OS.
	//
	DLT_ATM_RFC1483 = 11; // LLC-encapsulated ATM
	DLT_RAW         = 12; // raw IP

	//
	//  Given that the only OS that currently generates BSD/OS SLIP or PPP
	//  is, well, BSD/OS, arguably everybody should have chosen its values
	//  for DLT_SLIP_BSDOS and DLT_PPP_BSDOS, which are 15 and 16, but they
	//  didn't.  So it goes.
	//
	DLT_SLIP_BSDOS = 15; // BSD/OS Serial Line IP//
	DLT_PPP_BSDOS  = 16; // BSD/OS Point-to-point Protocol//
	//
	// 17 is used for DLT_OLD_PFLOG in OpenBSD;
	//     OBSOLETE: DLT_PFLOG is 117 in OpenBSD now as well. See below.
	// 18 is used for DLT_PFSYNC in OpenBSD; don't use it for anything else.
	//

	DLT_ATM_CLIP = 19; // Linux Classical-IP over ATM//

	//
	// Apparently Redback uses this for its SmartEdge 400/800.  I hope
	// nobody else decided to use it, too.
	//
	DLT_REDBACK_SMARTEDGE = 32;

	//
	// These values are defined by NetBSD; other platforms should refrain from
	// using them for other purposes, so that NetBSD savefiles with link
	// types of 50 or 51 can be read as this type on all platforms.
	//
	DLT_PPP_SERIAL = 50; // PPP over serial with HDLC encapsulation//
	DLT_PPP_ETHER  = 51; // PPP over Ethernet//

	//
	// The Axent Raptor firewall - now the Symantec Enterprise Firewall - uses
	// a link-layer type of 99 for the tcpdump it supplies.  The link-layer
	// header has 6 bytes of unknown data, something that appears to be an
	// Ethernet type, and 36 bytes that appear to be 0 in at least one capture
	// I've seen.
	//
	DLT_SYMANTEC_FIREWALL = 99;

	//
	// Values between 100 and 103 are used in capture file headers as
	// link-layer types corresponding to DLT_ types that differ
	// between platforms; don't use those values for new DLT_ new types.
	//

	//
	// This value was defined by libpcap 0.5; platforms that have defined
	// it with a different value should define it here with that value -
	// a link type of 104 in a save file will be mapped to DLT_C_HDLC,
	// whatever value that happens to be, so programs will correctly
	// handle files with that link type regardless of the value of
	// DLT_C_HDLC.
	//
	// The name DLT_C_HDLC was used by BSD/OS; we use that name for source
	// compatibility with programs written for BSD/OS.
	//
	// libpcap 0.5 defined it as DLT_CHDLC; we define DLT_CHDLC as well,
	// for source compatibility with programs written for libpcap 0.5.
	//
	DLT_C_HDLC = 104; // Cisco HDLC//
	DLT_CHDLC  = DLT_C_HDLC;

	DLT_IEEE802_11 = 105; // IEEE 802.11 wireless//

	//
	// 106 is reserved for Linux Classical IP over ATM; it's like DLT_RAW,
	// except when it isn't.  (I.e., sometimes it's just raw IP, and
	// sometimes it isn't.)  We currently handle it as DLT_LINUX_SLL,
	// so that we don't have to worry about the link-layer header.)
	//

	//
	// Frame Relay; BSD/OS has a DLT_FR with a value of 11, but that collides
	// with other values.
	// DLT_FR and DLT_FRELAY packets start with the Q.922 Frame Relay header
	// (DLCI, etc.).
	//
	DLT_FRELAY = 107;

	//
	// OpenBSD DLT_LOOP, for loopback devices; it's like DLT_NULL, except
	// that the AF_ type in the link-layer header is in network byte order.
	//
	// DLT_LOOP is 12 in OpenBSD, but that's DLT_RAW in other OSes, so
	// we don't use 12 for it in OSes other than OpenBSD.
	//
	DLT_LOOP = 108;

	//
	// Encapsulated packets for IPsec; DLT_ENC is 13 in OpenBSD, but that's
	// DLT_SLIP_BSDOS in NetBSD, so we don't use 13 for it in OSes other
	// than OpenBSD.
	//
	DLT_ENC = 109;

	//
	// Values between 110 and 112 are reserved for use in capture file headers
	// as link-layer types corresponding to DLT_ types that might differ
	// between platforms; don't use those values for new DLT_ types
	// other than the corresponding DLT_ types.
	//

	//
	// This is for Linux cooked sockets.
	//
	DLT_LINUX_SLL = 113;

	//
	// Apple LocalTalk hardware.
	//
	DLT_LTALK = 114;

	//
	// Acorn Econet.
	//
	DLT_ECONET = 115;

	//
	// Reserved for use with OpenBSD ipfilter.
	//
	DLT_IPFILTER = 116;

	//
	// OpenBSD DLT_PFLOG; DLT_PFLOG is 17 in OpenBSD, but that's DLT_LANE8023
	// in SuSE 6.3, so we can't use 17 for it in capture-file headers.
	//
	// XXX: is there a conflict with DLT_PFSYNC 18 as well?
	//
	DLT_PFLOG = 117;

	//
	// Registered for Cisco-internal use.
	//
	DLT_CISCO_IOS = 118;

	//
	// For 802.11 cards using the Prism II chips, with a link-layer
	// header including Prism monitor mode information plus an 802.11
	// header.
	//
	DLT_PRISM_HEADER = 119;

	//
	// Reserved for Aironet 802.11 cards, with an Aironet link-layer header
	// (see Doug Ambrisko's FreeBSD patches).
	//
	DLT_AIRONET_HEADER = 120;

	//
	// Reserved for Siemens HiPath HDLC.
	//
	DLT_HHDLC = 121;

	//
	// This is for RFC 2625 IP-over-Fibre Channel.
	//
	// This is not for use with raw Fibre Channel, where the link-layer
	// header starts with a Fibre Channel frame header; it's for IP-over-FC,
	// where the link-layer header starts with an RFC 2625 Network_Header
	// field.
	//
	DLT_IP_OVER_FC = 122;

	//
	// This is for Full Frontal ATM on Solaris with SunATM, with a
	// pseudo-header followed by an AALn PDU.
	//
	// There may be other forms of Full Frontal ATM on other OSes,
	// with different pseudo-headers.
	//
	// If ATM software returns a pseudo-header with VPI/VCI information
	// (and, ideally, packet type information, e.g. signalling, ILMI,
	// LANE, LLC-multiplexed traffic, etc.), it should not use
	// DLT_ATM_RFC1483, but should get a new DLT_ value, so tcpdump
	// and the like don't have to infer the presence or absence of a
	// pseudo-header and the form of the pseudo-header.
	//
	DLT_SUNATM = 123; // Solaris+SunATM//

	//
	// Reserved as per request from Kent Dahlgren <kent@praesum.com>
	// for private use.
	//
	DLT_RIO     = 124; // RapidIO//
	DLT_PCI_EXP = 125; // PCI Express//
	DLT_AURORA  = 126; // Xilinx Aurora link layer//

	//
	// Header for 802.11 plus a number of bits of link-layer information
	// including radio information, used by some recent BSD drivers as
	// well as the madwifi Atheros driver for Linux.
	//
	DLT_IEEE802_11_RADIO = 127; // 802.11 plus radiotap radio header//

	//
	// Reserved for the TZSP encapsulation, as per request from
	// Chris Waters <chris.waters@networkchemistry.com>
	// TZSP is a generic encapsulation for any other link type,
	// which includes a means to include meta-information
	// with the packet, e.g. signal strength and channel
	// for 802.11 packets.
	//
	DLT_TZSP = 128; // Tazmen Sniffer Protocol//

	//
	// BSD's ARCNET headers have the source host, destination host,
	// and type at the beginning of the packet; that's what's handed
	// up to userland via BPF.
	//
	// Linux's ARCNET headers, however, have a 2-byte offset field
	// between the host IDs and the type; that's what's handed up
	// to userland via PF_PACKET sockets.
	//
	// We therefore have to have separate DLT_ values for them.
	//
	DLT_ARCNET_LINUX = 129; // ARCNET//

	//
	// Juniper-private data link types, as per request from
	// Hannes Gredler <hannes@juniper.net>.  The DLT_s are used
	// for passing on chassis-internal metainformation such as
	// QOS profiles, etc..
	//
	DLT_JUNIPER_MLPPP    = 130;
	DLT_JUNIPER_MLFR     = 131;
	DLT_JUNIPER_ES       = 132;
	DLT_JUNIPER_GGSN     = 133;
	DLT_JUNIPER_MFR      = 134;
	DLT_JUNIPER_ATM2     = 135;
	DLT_JUNIPER_SERVICES = 136;
	DLT_JUNIPER_ATM1     = 137;

	//
	// Apple IP-over-IEEE 1394, as per a request from Dieter Siegmund
	// <dieter@apple.com>.  The header that's presented is an Ethernet-like
	// header:
	//
	//	FIREWIRE_EUI64_LEN = 8;
	//	struct firewire_header {
	//		u_char  firewire_dhost[FIREWIRE_EUI64_LEN];
	//		u_char  firewire_shost[FIREWIRE_EUI64_LEN];
	//		u_short firewire_type;
	//	};
	//
	// with "firewire_type" being an Ethernet type value, rather than,
	// for example, raw GASP frames being handed up.
	//
	DLT_APPLE_IP_OVER_IEEE1394 = 138;

	//
	// Various SS7 encapsulations, as per a request from Jeff Morriss
	// <jeff.morriss[AT]ulticom.com> and subsequent discussions.
	//
	DLT_MTP2_WITH_PHDR = 139; // pseudo-header with various info, followed by MTP2//
	DLT_MTP2           = 140; // MTP2, without pseudo-header//
	DLT_MTP3           = 141; // MTP3, without pseudo-header or MTP2//
	DLT_SCCP           = 142; // SCCP, without pseudo-header or MTP2 or MTP3//

	//
	// DOCSIS MAC frames.
	//
	DLT_DOCSIS = 143;

	//
	// Linux-IrDA packets. Protocol defined at http://www.irda.org.
	// Those packets include IrLAP headers and above (IrLMP...), but
	// don't include Phy framing (SOF/EOF/CRC & byte stuffing), because Phy
	// framing can be handled by the hardware and depend on the bitrate.
	// This is exactly the format you would get capturing on a Linux-IrDA
	// interface (irdaX), but not on a raw serial port.
	// Note the capture is done in "Linux-cooked" mode, so each packet include
	// a fake packet header (struct sll_header). This is because IrDA packet
	// decoding is dependant on the direction of the packet (incomming or
	// outgoing).
	// When/if other platform implement IrDA capture, we may revisit the
	// issue and define a real DLT_IRDA...
	// Jean II
	//
	DLT_LINUX_IRDA = 144;

	//
	// Reserved for IBM SP switch and IBM Next Federation switch.
	//
	DLT_IBM_SP = 145;
	DLT_IBM_SN = 146;

	//
	// Reserved for private use.  If you have some link-layer header type
	// that you want to use within your organization, with the capture files
	// using that link-layer header type not ever be sent outside your
	// organization, you can use these values.
	//
	// No libpcap release will use these for any purpose, nor will any
	// tcpdump release use them, either.
	//
	// Do//NOT* use these in capture files that you expect anybody not using
	// your private versions of capture-file-reading tools to read; in
	// particular, do//NOT* use them in products, otherwise you may find that
	// people won't be able to use tcpdump, or snort, or Ethereal, or... to
	// read capture files from your firewall/intrusion detection/traffic
	// monitoring/etc. appliance, or whatever product uses that DLT_ value,
	// and you may also find that the developers of those applications will
	// not accept patches to let them read those files.
	//
	// Also, do not use them if somebody might send you a capture using them
	// for//their* private type and tools using them for//your* private type
	// would have to read them.
	//
	// Instead, ask "tcpdump-workers@lists.tcpdump.org" for a new DLT_ value,
	// as per the comment above, and use the type you're given.
	//
	DLT_USER0  = 147;
	DLT_USER1  = 148;
	DLT_USER2  = 149;
	DLT_USER3  = 150;
	DLT_USER4  = 151;
	DLT_USER5  = 152;
	DLT_USER6  = 153;
	DLT_USER7  = 154;
	DLT_USER8  = 155;
	DLT_USER9  = 156;
	DLT_USER10 = 157;
	DLT_USER11 = 158;
	DLT_USER12 = 159;
	DLT_USER13 = 160;
	DLT_USER14 = 161;
	DLT_USER15 = 162;

	//
	// For future use with 802.11 captures - defined by AbsoluteValue
	// Systems to store a number of bits of link-layer information
	// including radio information:
	//
	//	http://www.shaftnet.org/~pizza/software/capturefrm.txt
	//
	// but it might be used by some non-AVS drivers now or in the
	// future.
	//
	DLT_IEEE802_11_RADIO_AVS = 163; // 802.11 plus AVS radio header//

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.  The DLT_s are used
	// for passing on chassis-internal metainformation such as
	// QOS profiles, etc..
	//
	DLT_JUNIPER_MONITOR = 164;

	//
	// Reserved for BACnet MS/TP.
	//
	DLT_BACNET_MS_TP = 165;

	//
	// Another PPP variant as per request from Karsten Keil <kkeil@suse.de>.
	//
	// This is used in some OSes to allow a kernel socket filter to distinguish
	// between incoming and outgoing packets, on a socket intended to
	// supply pppd with outgoing packets so it can do dial-on-demand and
	// hangup-on-lack-of-demand; incoming packets are filtered out so they
	// don't cause pppd to hold the connection up (you don't want random
	// input packets such as port scans, packets from old lost connections,
	// etc. to force the connection to stay up).
	//
	// The first byte of the PPP header (0xff03) is modified to accomodate
	// the direction - 0x00 = IN, 0x01 = OUT.
	//
	DLT_PPP_PPPD = 166;

	//
	// Names for backwards compatibility with older versions of some PPP
	// software; new software should use DLT_PPP_PPPD.
	//
	DLT_PPP_WITH_DIRECTION      = DLT_PPP_PPPD;
	DLT_LINUX_PPP_WITHDIRECTION = DLT_PPP_PPPD;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.  The DLT_s are used
	// for passing on chassis-internal metainformation such as
	// QOS profiles, cookies, etc..
	//
	DLT_JUNIPER_PPPOE     = 167;
	DLT_JUNIPER_PPPOE_ATM = 168;

	DLT_GPRS_LLC = 169; // GPRS LLC//
	DLT_GPF_T    = 170; // GPF-T (ITU-T G.7041/Y.1303)//
	DLT_GPF_F    = 171; // GPF-F (ITU-T G.7041/Y.1303)//

	//
	// Requested by Oolan Zimmer <oz@gcom.com> for use in Gcom's T1/E1 line
	// monitoring equipment.
	//
	DLT_GCOM_T1E1   = 172;
	DLT_GCOM_SERIAL = 173;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.  The DLT_ is used
	// for internal communication to Physical Interface Cards (PIC)
	//
	DLT_JUNIPER_PIC_PEER = 174;

	//
	// Link types requested by Gregor Maier <gregor@endace.com> of Endace
	// Measurement Systems.  They add an ERF header (see
	// http://www.endace.com/support/EndaceRecordFormat.pdf) in front of
	// the link-layer header.
	//
	DLT_ERF_ETH = 175; // Ethernet//
	DLT_ERF_POS = 176; // Packet-over-SONET//

	//
	// Requested by Daniele Orlandi <daniele@orlandi.com> for raw LAPD
	// for vISDN (http://www.orlandi.com/visdn/).  Its link-layer header
	// includes additional information before the LAPD header, so it's
	// not necessarily a generic LAPD header.
	//
	DLT_LINUX_LAPD = 177;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.
	// The DLT_ are used for prepending meta-information
	// like interface index, interface name
	// before standard Ethernet, PPP, Frelay & C-HDLC Frames
	//
	DLT_JUNIPER_ETHER  = 178;
	DLT_JUNIPER_PPP    = 179;
	DLT_JUNIPER_FRELAY = 180;
	DLT_JUNIPER_CHDLC  = 181;

	//
	// Multi Link Frame Relay (FRF.16)
	//
	DLT_MFR = 182;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.
	// The DLT_ is used for internal communication with a
	// voice Adapter Card (PIC)
	//
	DLT_JUNIPER_VP = 183;

	//
	// Arinc 429 frames.
	// DLT_ requested by Gianluca Varenni <gianluca.varenni@cacetech.com>.
	// Every frame contains a 32bit A429 label.
	// More documentation on Arinc 429 can be found at
	// http://www.condoreng.com/support/downloads/tutorials/ARINCTutorial.pdf
	//
	DLT_A429 = 184;

	//
	// Arinc 653 Interpartition Communication messages.
	// DLT_ requested by Gianluca Varenni <gianluca.varenni@cacetech.com>.
	// Please refer to the A653-1 standard for more information.
	//
	DLT_A653_ICM = 185;

	//
	// USB packets, beginning with a USB setup header; requested by
	// Paolo Abeni <paolo.abeni@email.it>.
	//
	DLT_USB = 186;

	//
	// Bluetooth HCI UART transport layer (part H:4); requested by
	// Paolo Abeni.
	//
	DLT_BLUETOOTH_HCI_H4 = 187;

	//
	// IEEE 802.16 MAC Common Part Sublayer; requested by Maria Cruz
	// <cruz_petagay@bah.com>.
	//
	DLT_IEEE802_16_MAC_CPS = 188;

	//
	// USB packets, beginning with a Linux USB header; requested by
	// Paolo Abeni <paolo.abeni@email.it>.
	//
	DLT_USB_LINUX = 189;

	//
	// Controller Area Network (CAN) v. 2.0B packets.
	// DLT_ requested by Gianluca Varenni <gianluca.varenni@cacetech.com>.
	// Used to dump CAN packets coming from a CAN Vector board.
	// More documentation on the CAN v2.0B frames can be found at
	// http://www.can-cia.org/downloads/?269
	//
	DLT_CAN20B = 190;

	//
	// IEEE 802.15.4, with address fields padded, as is done by Linux
	// drivers; requested by Juergen Schimmer.
	//
	DLT_IEEE802_15_4_LINUX = 191;

	//
	// Per Packet Information encapsulated packets.
	// DLT_ requested by Gianluca Varenni <gianluca.varenni@cacetech.com>.
	//
	DLT_PPI = 192;

	//
	// Header for 802.16 MAC Common Part Sublayer plus a radiotap radio header;
	// requested by Charles Clancy.
	//
	DLT_IEEE802_16_MAC_CPS_RADIO = 193;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.
	// The DLT_ is used for internal communication with a
	// integrated service module (ISM).
	//
	DLT_JUNIPER_ISM = 194;

	//
	// IEEE 802.15.4, exactly as it appears in the spec (no padding, no
	// nothing); requested by Mikko Saarnivala <mikko.saarnivala@sensinode.com>.
	//
	DLT_IEEE802_15_4 = 195;

	//
	// Various link-layer types, with a pseudo-header, for SITA
	// (http://www.sita.aero/); requested by Fulko Hew (fulko.hew@gmail.com).
	//
	DLT_SITA = 196;

	//
	// Various link-layer types, with a pseudo-header, for Endace DAG cards;
	// encapsulates Endace ERF records.  Requested by Stephen Donnelly
	// <stephen@endace.com>.
	//
	DLT_ERF = 197;

	//
	// Special header prepended to Ethernet packets when capturing from a
	// u10 Networks board.  Requested by Phil Mulholland
	// <phil@u10networks.com>.
	//
	DLT_RAIF1 = 198;

	//
	// IPMB packet for IPMI, beginning with the I2C slave address, followed
	// by the netFn and LUN, etc..  Requested by Chanthy Toeung
	// <chanthy.toeung@ca.kontron.com>.
	//
	DLT_IPMB = 199;

	//
	// Juniper-private data link type, as per request from
	// Hannes Gredler <hannes@juniper.net>.
	// The DLT_ is used for capturing data on a secure tunnel interface.
	//
	DLT_JUNIPER_ST = 200;

	//
	// Bluetooth HCI UART transport layer (part H:4), with pseudo-header
	// that includes direction information; requested by Paolo Abeni.
	//
	DLT_BLUETOOTH_HCI_H4_WITH_PHDR = 201;

	//
	// AX.25 packet with a 1-byte KISS header; see
	//
	//	http://www.ax25.net/kiss.htm
	//
	// as per Richard Stearn <richard@rns-stearn.demon.co.uk>.
	//
	DLT_AX25_KISS = 202;

	//
	// LAPD packets from an ISDN channel, starting with the address field,
	// with no pseudo-header.
	// Requested by Varuna De Silva <varunax@gmail.com>.
	//
	DLT_LAPD = 203;

	//
	// Variants of various link-layer headers, with a one-byte direction
	// pseudo-header prepended - zero means "received by this host",
	// non-zero (any non-zero value) means "sent by this host" - as per
	// Will Barker <w.barker@zen.co.uk>.
	//
	DLT_PPP_WITH_DIR    = 204; // PPP - don't confuse with DLT_PPP_WITH_DIRECTION//
	DLT_C_HDLC_WITH_DIR = 205; // Cisco HDLC//
	DLT_FRELAY_WITH_DIR = 206; // Frame Relay//
	DLT_LAPB_WITH_DIR   = 207; // LAPB//

	//
	// 208 is reserved for an as-yet-unspecified proprietary link-layer
	// type, as requested by Will Barker.
	//

	//
	// IPMB with a Linux-specific pseudo-header; as requested by Alexey Neyman
	// <avn@pigeonpoint.com>.
	//
	DLT_IPMB_LINUX = 209;

	//
	// FlexRay automotive bus - http://www.flexray.com/ - as requested
	// by Hannes Kaelber <hannes.kaelber@x2e.de>.
	//
	DLT_FLEXRAY = 210;

	//
	// Media Oriented Systems Transport (MOST) bus for multimedia
	// transport - http://www.mostcooperation.com/ - as requested
	// by Hannes Kaelber <hannes.kaelber@x2e.de>.
	//
	DLT_MOST = 211;

	//
	// Local Interconnect Network (LIN) bus for vehicle networks -
	// http://www.lin-subbus.org/ - as requested by Hannes Kaelber
	// <hannes.kaelber@x2e.de>.
	//
	DLT_LIN = 212;

	//
	// X2E-private data link type used for serial line capture,
	// as requested by Hannes Kaelber <hannes.kaelber@x2e.de>.
	//
	DLT_X2E_SERIAL = 213;

	//
	// X2E-private data link type used for the Xoraya data logger
	// family, as requested by Hannes Kaelber <hannes.kaelber@x2e.de>.
	//
	DLT_X2E_XORAYA = 214;

	//
	// IEEE 802.15.4, exactly as it appears in the spec (no padding, no
	// nothing), but with the PHY-level data for non-ASK PHYs (4 octets
	// of 0 as preamble, one octet of SFD, one octet of frame length+
	// reserved bit, and then the MAC-layer data, starting with the
	// frame control field).
	//
	// Requested by Max Filippov <jcmvbkbc@gmail.com>.
	//
	DLT_IEEE802_15_4_NONASK_PHY = 215;

	//
	// NetBSD-specific generic "raw" link type.  The class value indicates
	// that this is the generic raw type, and the lower 16 bits are the
	// address family we're dealing with.  Those values are NetBSD-specific;
	// do not assume that they correspond to AF_ values for your operating
	// system.
	//
	DLT_CLASS_NETBSD_RAWAF = $02240000;

	//
	// The instruction encodings.
	//

	// instruction classes
	BPF_LD   = $00;
	BPF_LDX  = $01;
	BPF_ST   = $02;
	BPF_STX  = $03;
	BPF_ALU  = $04;
	BPF_JMP  = $05;
	BPF_RET  = $06;
	BPF_MISC = $07;

	// ld/ldx fields
	BPF_W   = $00;
	BPF_H   = $08;
	BPF_B   = $10;
	BPF_IMM = $00;
	BPF_ABS = $20;
	BPF_IND = $40;
	BPF_MEM = $60;
	BPF_LEN = $80;
	BPF_MSH = $A0;

	// alu/jmp fields
	BPF_ADD  = $00;
	BPF_SUB  = $10;
	BPF_MUL  = $20;
	BPF_DIV  = $30;
	BPF_OR   = $40;
	BPF_AND  = $50;
	BPF_LSH  = $60;
	BPF_RSH  = $70;
	BPF_NEG  = $80;
	BPF_JA   = $00;
	BPF_JEQ  = $10;
	BPF_JGT  = $20;
	BPF_JGE  = $30;
	BPF_JSET = $40;
	BPF_K    = $00;
	BPF_X    = $08;

	// ret - BPF_K and BPF_X also apply
	BPF_A = $10;

	// misc
	BPF_TAX = $00;
	BPF_TXA = $80;

	//
	// DLT and savefile link type values are split into a class and
	// a member of that class.  A class value of 0 indicates a regular
	// DLT_/LINKTYPE_ value.
	//
function DLT_CLASS(c: u_int): u_int;

function DLT_NETBSD_RAWAF(af: u_int): u_int;
function DLT_NETBSD_RAWAF_AF(c: u_int): u_int;
function DLT_IS_NETBSD_RAWAF(c: u_int): boolean;

function BPF_CLASS(code: word): word;
function BPF_SIZE(code: word): word;
function BPF_MODE(code: word): word;
function BPF_OP(code: word): word;
function BPF_SRC(code: word): word;
function BPF_RVAL(code: word): word;
function BPF_MISCOP(code: word): word;

//
//  Macros for insn array initializers.
//
//  #define BPF_STMT(code, k) { (u_short)(code), 0, 0, k }
//  #define BPF_JUMP(code, k, jt, jf) { (u_short)(code), jt, jf, k }

implementation

function BPF_WORDALIGN(x: integer): integer;
begin
	Result := (x + BPF_ALIGNMENT - 1) and not (BPF_ALIGNMENT - 1);
end;

function DLT_CLASS(c: u_int): u_int;
begin
	Result := (c and $03FF0000);
end;

function DLT_NETBSD_RAWAF(af: u_int): u_int;
begin
	Result := (DLT_CLASS_NETBSD_RAWAF or af);
end;

function DLT_NETBSD_RAWAF_AF(c: u_int): u_int;
begin
	Result := (c and $0000FFFF)
end;

function DLT_IS_NETBSD_RAWAF(c: u_int): boolean;
begin
	Result := (DLT_CLASS(c) = DLT_CLASS_NETBSD_RAWAF);
end;

function BPF_CLASS(code: word): word;
begin
	Result := (code and $07);
end;

function BPF_SIZE(code: word): word;
begin
	Result := (code and $18);
end;

function BPF_MODE(code: word): word;
begin
	Result := (code and $E0);

end;

function BPF_OP(code: word): word;
begin
	Result := (code and $F0);

end;

function BPF_SRC(code: word): word;
begin
	Result := (code and $08);

end;

function BPF_RVAL(code: word): word;
begin
	Result := (code and $18);

end;

function BPF_MISCOP(code: word): word;
begin
	Result := (code and $F8);

end;

end.
