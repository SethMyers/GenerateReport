#!/bin/bash

#downloads all pngs for report
wget -r -A png --user=uname --password=pass --no-check-certificate https://oasis.solutionip.com/mun/report.html || (echo 'wget failed getting .png images'; exit 1; )


#moves fetched files around so they can be easily accessed
cd oasis.solutionip.com
cd battery
mv battery_bandwidth_*.png ../..
cd ..
cd mun
mv bandwidth_wan_*.png ../..
mv connected*.png ../..
cd ..
cd ..
mv bandwidth*.png bandwidth_wan.png
mv battery*.png battery_bandwidth.png
mv connected*.png connected_wireless_devices.png 

#cookie for access to dashboard
curl -vd "page=page&username=uname&password=pass" -c cookiejar https://smart.solutionip.com/login.cgi

#fetches information for up/downloaded data breakdown graphs
curl -d "property_id=225&page=network&start_date=$(date -d'yesterday' +%Y-%m-%d)&end_date=$(date -d 'yesterday' +%Y-%m-%d)" -b cookiejar https://smart.solutionip.com/index.cgi > info.json

./generategraph.py

trml2pdf /dev/stdin <<EOF

<!DOCTYPE document SYSTEM "rml.dtd"> 
<document filename="$(date +'mun_report_%Y_%m_%d.pdf')" invariant="1">

<template pageSize="(612, 792)">
	  <pageTemplate id="first">
	  	   <pageGraphics>
			<image file="MUN_Logo_RGB.png" preserveAspectRatio="1" x="50" y="450" width="500" height="310"/>
			<setFont name="Helvetica" size="24" />
			<drawCentredString x="4.25in" y="4.5in">Daily Network Report</drawCentredString>
			<setFont name="Helvetica" size="20"/>
			<drawCentredString x="4.25in" y="4.2in">$(date +'%b %d, %Y')</drawCentredString>
			<image file="logo.png" preserveAspectRatio="1" x="300" y="100" width="250"/>
		   </pageGraphics>
 		   <frame id="first" x1="100" y1="400" width="612" height="792"/>
	  </pageTemplate>
	  <pageTemplate id="second">
	  	   <pageGraphics>
			<image file="bandwidth_wan.png" preserveAspectRatio="1" x="1" y="450" width="500" height="310"/>
			<image file="battery_bandwidth.png" preserveAspectRatio="1" x="1" y="100" width="500" height="310"/>
		   </pageGraphics>
 		   <frame id="first" x1="100" y1="500" width="612" height="792"/>
	  </pageTemplate>
	  <pageTemplate id="third">
	  	   <pageGraphics>
			<image file="connected_wireless_devices.png" preserveAspectRatio="1" x="1" y="450" width="500" height="310"/>
		   	<image file="my_mun_barchart.png" preserveAspectRatio="1" x="1" y="100" width="500" height="310"/>
		   </pageGraphics>
		   <frame id="first" x1="100" y1="500" width="612" height="792"/>
	  </pageTemplate>
</template>


<story>
	<setNextTemplate name="second"/>
	<nextFrame/>
	<para>
		Bandwidth (WAN) Usage (24 Hour Period) - 1000 Mbit Cap
	</para>
	<illustration>		
      	</illustration>
	<setNextTemplate name="third"/>
	<nextFrame/>
	<illustration></illustration>
</story>
</document>

EOF

#removes files used in the report to avoid having to keep three .png files every day
rm bandwidth_wan.png
rm battery_bandwidth.png
rm connected_wireless_devices.png
