#!/bin/bash
#./cannibal.sh userid
USERID=$1

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
	page=`curl -s "http://www.delicious.com/$USERID/?detail=2&setcount=100&page=$pageNum"`
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

page=`curl -s -s "http://www.delicious.com/$USERID"`
bookcount=`echo $page|grep -o "<p>[0-9][0-9]* Bookmarks</p>"|grep -o "[0-9]*"`
tagcount=`echo $page|grep -o "All Tags</span> <em>[0-9]*</em>"|grep -o "[0-9]*"`
top10tags=`echo $page|grep -oP "Top 10 Tags.*?</ul>"|grep -oP "span t.*?\">.*?<em>[0-9]*"|sed -e 's/span title=".*">//' -e 's/<em>/-/'`
alias=`echo $page|grep -oP "<em class=\".*?\">.*?'s</em>"|sed -e "s/<em class=\".*\">//" -e "s/'s<\/em>//"`
sleep 1
alltags=`curl -s http://feeds.delicious.com/v2/json/refineByTag/$USERID?callback=Delicious.TagData.callbackMagicData|grep -oP "tag\":\".*?\",\"count\":[0-9]*"|tr "\":" " "|awk '{print $2"-"$NF}'`
echo "<user>"
tab
echo "<userID>$USERID</userID>"
tab
echo "<alias>$alias</alias>"
tab
echo "<stats>"
tab;tab
echo "<bookmarks>$bookcount</bookmarks>"
tab;tab
echo "<tags>$tagcount</tags>"
tab
echo "</stats>"
#echo "Top 10 tags:"
tab
echo "<top10tags>"
for i in `echo $top10tags`
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
echo "</top10tags>"

tab
echo "<allTags>"
for i in `echo $alltags`
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
echo "</allTags>"
extractBookmarks $bookcount
echo "</user>"