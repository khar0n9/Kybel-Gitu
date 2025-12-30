1. z template treba zobrat spravny port konfig a prepisat vlany/description proste cele telo a treba este prepisat 
cislo portu na (x)

interface GigabitEthernet1/(x)
 description [Office]/[cable ID]
 switchport access vlan 2024
 switchport mode access
 switchport voice vlan 2064
 switchport port-security maximum 3
 switchport port-security aging time 1
 switchport port-security aging type inactivity
 switchport port-security
 no logging event link-status
 load-interval 60
 power inline police
 ipv6 nd raguard attach-policy pp6_raguard_client
 ipv6 dhcp guard attach-policy pp6_dhcp_client
 no snmp trap link-status
 flowcontrol receive off
 flowcontrol send off
 storm-control broadcast include multicast
 storm-control broadcast level bps 50m
 spanning-tree portfast edge
 spanning-tree bpduguard enable
 service-policy output pm_att_queuing
 ip dhcp snooping limit rate 10
 no shutdown
!

2. telo konfigu si skopiruj (bez vykricnikov)
3. dopln vykricnik za konfig a posun kurzor o riadok nizssie pod vykricnik
4. spusti skript 
5. prva hodnota je cislo od ktoreho sa ma cislovat (x) takze ak mame prve 2 port napr APcka tak prva hodnota je 3
6. druha tabulka sa nas pyta na to kolko krat chcem napastit takze treba dat aj tento pocet
7. voala

umiestnenie skriptu > C:\Users\pk922g\OneDrive - AT&T Services, Inc\Desktop\notepad++\npp.8.4.1.portable.x64\plugins\Config\PythonScript\scripts
Skript zoberie to co je skopirovane a napastuje to x-krat s parametrom (x)
nasledne skript prepisuje zostupne (x) od specifikovaneho cisla az po cislo ktore si tiez zaspecifikujeme vramci poctu opakovani kopirovania