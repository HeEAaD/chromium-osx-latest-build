#!/bin/sh
# Get the latest nightly build of Chromium for OS X
# 
# @version  2010-01-12
# @author   XXXX
# @author   Mustafa K. Isik - isik@acm.org
# @author   Steffen Matthischke - steffen.matthischke@gmail.com
#
# make this bash script executable: chmod a+x <name-of-this-file>
# execute it via: ./<name-of-this-file>

# setup ------------------------------------------------------------------------
tempDir="/tmp/`whoami`/chrome-nightly/";
baseURL="http://build.chromium.org/buildbot/snapshots/chromium-rel-mac/";
baseName="chrome-mac";
baseExt="zip";
appName="Chromium.app";
appDir="/Applications";
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
function checkForErrors {
    if [ "$?" != "0" ]; then
        echo "Unkown error (see above for help)!";
        exit 3;
    fi
}
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Setup...";
mkdir -p "$tempDir";
cd "$tempDir";
checkForErrors;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Checking current version...";
xmlStringValue=`grep -A1 '<key>SVNRevision</key>' $appDir/$appName/Contents/Info.plist`;
checkForErrors;
currentVersion=${xmlStringValue##*<string>};
currentVersion=${currentVersion%%</string>*};
latestVersion=`curl -s $baseURL/LATEST`;
checkForErrors;
echo " * your/latest build: $currentVersion / $latestVersion";
if [ "$currentVersion" == "$latestVersion" ]; then
    echo " * build $currentVersion is the latest one.";
    exit 1;
fi
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
echo "Downloading ...";
chromePID=`ps wwaux|grep -v grep|grep "$appName"|awk '{print $2}'`;
if [ "$chromePID" != "" ];then
    echo " * Please quit Chromium.";
    exit 2;
fi
curl -o $baseName.$baseExt "$baseURL/$latestVersion/$baseName.$baseExt";
echo "Unpacking ..."
unzip -qo $baseName.$baseExt;
checkForErrors;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Installing...";
cp -r $baseName/$appName $appDir
checkForErrors;
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
echo "Done. You are now running build $latestVersion";
changelog=`curl -s $baseURL/$latestVersion/changelog.xml`;
checkForErrors;
changelog=${changelog##*revision="$lastestVersion"};
changelog=${changelog##*<msg>};
changelog=${changelog%%</msg>*};
echo "--------------------------------------------------------------------------------
Log Message:\n$changelog
--------------------------------------------------------------------------------";
# ------------------------------------------------------------------------------