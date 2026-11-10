# Controlled Packet Capture and 802.11 Protocol Analysis Lab

A hands-on, build-it-yourself lab series for learning 802.11 (Wi-Fi) protocol analysis through packet capture, without needing production networks, vendor access points, or someone else's pcaps.

## Purpose

Many people learning wireless run into the same obstacles:

- They want to learn 802.11 but don't have access to pcaps or access points.
- They are studying for an exam and need to test and learn through protocol analysis.
- They understand the 4-way handshake "kind of, but not really."
- They don't want to capture on live networks and would rather use a lab.
- They want to test a feature and understand it before attempting it in production.
- They want to learn EAP, troubleshoot authentication methods, or identify retries.

This series addresses those obstacles by building a **repeatable, low-impact, low-cost wireless lab** from free, readily available software and inexpensive external wireless LAN adapters. Each lab then uses that environment to produce and analyze real captures of a specific protocol behavior.

## Philosophy

This series favors **building your own lab over using a pre-configured one**. Figuring out what needs to be built, and fixing it when it breaks, is a large part of the learning. Treat each lab as a starting point: change the settings, break things on purpose, and capture what happens.

## Who this is for

- Students preparing for wireless or networking certification exams
- Network and wireless engineers who want to sharpen packet-analysis skills
- Anyone troubleshooting Wi-Fi who wants to see exactly what is happening on the air
- Anyone comfortable with a Linux command line who wants to learn by doing

Basic Linux familiarity is assumed. Prior 802.11 knowledge is not required; the early labs build the foundation.

## Lab environment

### Hardware

| Component | Purpose |
|---|---|
| Linux system with root access (developed on Linux Mint 22 "Wilma") | Hosts the access point and supplicant |
| Wireless adapter that supports AP mode and monitor mode (developed with Panda Wireless PAU0F AXE3000) | Provides the access point and client (supplicant) interfaces |
| A second adapter or system that supports monitor mode | Provides clean over-the-air capture |

### Software

| Package | Role |
|---|---|
| `hostapd` | Turns a wireless interface into an access point |
| `wpa_supplicant` | Acts as the client (supplicant) |
| `dnsmasq` | Provides DHCP for the lab network |
| `iw` | Configures and inspects wireless interfaces and regulatory domain |
| `aircrack-ng` suite | `airmon-ng` creates the monitor interface; `airodump-ng` shows nearby networks |
| `wireshark` | Captures and analyzes frames |

### Topology

- **Access point and supplicant** - Two adapters on one Linux system, running `hostapd` and `wpa_supplicant`.
- **Capture point** -  A monitor-mode interface (`wlan0mon`) that records the exchange over the air.
- **Addressing**  - The lab DHCP range uses `192.0.2.0/24` (TEST-NET-1, RFC 5737), which is reserved for documentation and is not routable.
- **Test SSID** -  `PCAP-Lab`

Interface names and MAC addresses in the labs are examples from the author's system. Substitute your own

### Lab-only values

Passphrases and credentials shown in configuration files (for example `Testlab12345`, `WrongPSK`, `mypassword`) are placeholders for an isolated lab. Do not reuse them anywhere real.

## Labs

Work through the labs in order. Each one builds on the previous.

- **Lab Setup** - Required hardware and software, identifying adapters, setting the regulatory domain, and bringing up a working AP with `hostapd` and DHCP with `dnsmasq`
- **Lab Setup: aircrack-ng and Wireshark** - The aircrack-ng tools, creating a monitor interface with `airmon-ng`, Wireshark permissions, and importing community Wireshark profiles
- **Understanding 802.11 Frames** - The structure of the 802.11 MAC frame and a field-by-field look at Frame Control (Type, Subtype, flags)
- **WPA-PSK Analysis** - Reading the Frame Control and MAC header in a real capture, then comparing a successful 4-way handshake with a failed one caused by a wrong PSK
- **EAP-PEAP Validation** - Identifying 802.1X/EAP via the AKM suite, identifying the EAP type, what server certificate validation failure looks like, why skipping validation is risky, and exporting certificates from a capture
- **Retries and Pseudo Headers** - The Retry bit in Frame Control, what retries can indicate, and using radio metadata (such as signal strength) to narrow down causes

### Planned

Additional labs will follow and will build on this foundation. This list will be updated as each one is published.

## How to use this series

1. **Build the lab first** (Labs 1 and 2). Don't skip this; every later lab depends on it.
2. **Read the lab, then reproduce it.** Capture your own traffic rather than only reading the screenshots.
3. **Change one thing at a time.** Alter a setting, capture again, and compare the two captures.
4. **Keep your captures.** Name them descriptively so you can revisit and compare them later.
5. **Treat captures as evidence.** A frame in a capture shows what your sniffer heard, which is not always what the receiver heard.

### Tips

- Start captures with (**no capture filters**) when you can. Filters reduce noise but also narrow what you can see.
- Use the community Wireshark profiles recommended in Lab 2 to speed up your display-filter work.
- Memorize the MAC frame layout. It will pay off in every lab.

## Scope and responsible use

This series is for learning protocol analysis in a **controlled lab you own**.

- Only capture and test on equipment and networks you own or have explicit permission to test.
- The labs focus on `airmon-ng` and `airodump-ng`. They intentionally do not use the injection or key-cracking tools in the aircrack-ng suite.
- Regulatory rules vary by country. Set the regulatory domain for your location (the labs use US) and stay within it.

## Adding a new lab

To keep the series consistent, each new lab should include:

- **A short introduction** stating what the lab covers and why it matters
- **Lab setup**: the physical and logical diagrams, plus any configuration files used
- **Capture steps**: how to reproduce the behavior
- **Analysis**: the Wireshark display filters and fields to look at, with screenshots
- **Conclusion** and a pointer to the next lab

Add the new lab to the list above in order.

## Acknowledgements

Thanks to the wireless community for the shared Wireshark profiles that make analysis faster, including those from WLAN Professionals and Rasika Nayanajith (mrncciew.com).
