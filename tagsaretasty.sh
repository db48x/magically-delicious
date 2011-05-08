#!/bin/bash
#./cannibal.sh userid
TAG=$1

function tab
{
	echo -ne "\t"
}

function extractBookmarks
{
	count=$1
	pagecount=$((count/100+1))
	tab
	echo "<bookmarks>"
	for pageNum in `seq 1 $pagecount`; do
	sleep 1
	page=`curl -s "http://www.delicious.com/tag/$TAG?setcount=100&page=$pageNum"`
	echo $page|grep -oP "<li class=\"post.*>.*? #meta -->"|sed 's/<!-- #meta --> <\/li>/\n/g'|while read blob; do
		id=`echo $blob|grep -oP "item-[a-z0-9A-Z]*"|sed 's/item-//'`
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
		echo "<bookmark>"
		tab;tab;tab
		echo "<id>$id</id>"
		tab;tab;tab
		echo "<date>`date -u -d \"$date\" +%s`</date>"
		tab;tab;tab
		echo "<title>$title</title>"
		tab;tab;tab
		echo "<url>$url</url>"
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
	echo "</bookmarks>"
}

page=`curl -s -s "http://www.delicious.com/tag/$TAG"`
bookcount=`echo $page|grep -o "<p>[0-9][0-9]* Bookmarks</p></div>"|grep -o "[0-9]*"`
echo "<tag>"
tab
echo "<id>$TAG</id>"
tab
echo "<stats>"
tab;tab
echo "<bookmarks>$bookcount</bookmarks>"
tab
echo "</stats>"
extractBookmarks $bookcount
echo "</tag>"