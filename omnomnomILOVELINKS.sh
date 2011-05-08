#!/bin/bash
#./cannibal.sh userid
ID=$1

function tab
{
	echo -ne "\t"
}

function extractBookmarks
{
	count=$1
	pagecount=$((count/100+2))
	tab
	echo "<users>"
	for pageNum in `seq 1 $pagecount`; do
	sleep 1
	page=`curl -s "http://www.delicious.com/url/$ID?page=$pageNum&show=all"`
	echo $page|grep -oP "<li class=\"post.*>.*? #meta -->"|sed 's/<!-- #meta --> <\/li>/\n/g'|while read blob; do
		id=`echo $blob|grep -oP "href=\"/.*?\" class=\"user"|tr -d "\""|tr "/" " "|sed -e 's/href= //' -e 's/ class=.*//'`
		titleurl=`echo $blob|grep -oP "a rel=\"nofollow\" class=\"taggedlink \" href=\".*?\" >.*?</a>"`
		url=`echo $titleurl|grep -oP "href=\".*?\""|tr -d "\""|sed 's/href=//'`
		title=`echo $titleurl|grep -oP ">.*?<"|tr -d "><"`
		tagblob=`echo $blob|grep -oP "<div class=\"meta\">.*?<div class=\"clr\"></div>"|grep -oP "<a class=\"tag noplay\" rel=\"tag\" href=\".*?\">.*?</a>"|grep -oP ">.*?<"|tr -d "><"`
		date=`echo $blob|grep -oP "<div class=\"dateGroup\" title=\".*?\">"|grep -oP "[0-9][0-9]*.*?\""|tr -d "\""`
		if [ -z "$date" ]; then
			date=$oldDate;
		else
			oldDate=$date;
		fi
		tab;tab
		echo "<user>"
		tab;tab;tab
		echo "<id>$id</id>"
		tab;tab;tab
		echo "<dateBookmarked>`date -u -d \"$date\" +%s`</dateBookmarked>"
		tab;tab;tab
		echo "<tags>"
		for i in `echo $tagblob`; do
			tab;tab;tab;tab
			echo "<tag>"
			tab;tab;tab;tab;tab
			echo "<title>$i</title>"
			tab;tab;tab;tab
			echo "</tag>"
		done
		tab;tab;tab
		echo "</tags>"
		tab;tab
		echo "</bookmark>"
	done
	done
	tab
	echo "</users>"
}
page=`curl -s -s "http://www.delicious.com/url/$ID"`

url=`echo $page|grep -oP "<p id=\"url\"><a href=\"http://www.mwaw.net/2007/12/08/davies/\">"|sed -e 's/<p id="url"><a href="//' -e 's/">//'`
link=`wget -O - -q "$url"`
title=`echo $link|grep -oP "<title>.*?</title>"|sed -e 's/<title>//' -e 's/<\/title>//'`
countNGraphShit=`echo $page|grep -oP "<h3 class=\"everyone\">.*?bookmarklist_everyone"`
savecount=`echo $countNGraphShit|grep -oP "Saved [0-9]* times"|grep -o "[0-9]*"`
firstUser=`echo $countNGraphShit|grep -oP "first saved by <a href=\"/.*?\">.*?<"|tr "><" " "|awk '{print $NF}'`
dateAdded=$(date -u +%s -d "`echo $countNGraphShit|grep -oP "on .*?\."|tr -d "."|sed 's/on //'`")
chartURL=`echo $countNGraphShit|grep -oP "http://l.yimg.com/hr/graph/.*?.png"`
wget -O $ID.png $chartURL
wget -O $ID.html $url
tags=`echo $page|grep -oP "Top Tags.*?</ul>"|grep -oP "span t.*?\">.*?<em>[0-9]*"|sed -e 's/span title=".*">//' -e 's/<em>/-/'`
#sleep 1
#alltags=`curl -s http://feeds.delicious.com/v2/json/refineByTag/$USERID?callback=Delicious.TagData.callbackMagicData|grep -oP "tag\":\".*?\",\"count\":[0-9]*"|tr "\":" " "|awk '{print $2"-"$NF}'`
echo "<bookmark>"
tab
echo "<id>$ID</id>"
tab
echo "<title>$title</title>"
tab
echo "<url>$url</url>"
tab
echo "<chartURL>$chartURL</chartURL>"
tab
echo "<stats>"
tab;tab
echo "<firstAdded>"
tab;tab;tab
echo "<date>$dateAdded</date>"
tab;tab;tab
echo "<user>$firstUser</user>"
tab;tab
echo "</firstAdded>"
tab;tab
echo "<saveCount>$savecount</saveCount>"
tab
echo "</stats>"
tab
echo "<topTags>"
for i in `echo $tags`
	do title=`echo $i|sed "s/-[0-9][0-9]*//"`
	count=`echo $i|tr "-" " "|awk '{print $NF}'`
	tab;tab
	echo "<tag>"
	tab;tab;tab
	echo "<title>$title</title>"
	tab;tab;tab
	echo "<count>$count</count>"
	tab;tab
	echo "</tag>"
done
tab
echo "</topTags>"
extractBookmarks $savecount
echo "</bookmark>"