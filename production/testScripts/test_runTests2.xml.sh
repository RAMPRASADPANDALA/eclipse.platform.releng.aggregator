#!/usr/bin/env bash


#   Utility to test the runTests2.xml file. It's intended to allow rapid confirmation
#   that the runTests2.xml file computes correct values, for various versions platforms
#   and various versions of java and ant, etc. 

#   In particular, ant can be invoked with one version of java, but another version
#   of java used to actually run the tests.

#   In addition to the console output. which should be captured, with something like
#      ./testTextXMLScript.sh | tee testoutput.txt
#   some data or set-up files will be created as they normally would if running the real tests.
#   The can be checked to be sure they are correct, and in correct (relative) locations.

# unset some common variables which we don't want (or, set ourselves)
unset JAVA_HOME
unset JAVA_ROOT
unset JAVA_JRE
unset CLASSPATH
unset JAVA_BINDIR
unset JRE_HOME

function clean()
{

  echo -e "\n Cleaning previous results, as requested."
  # remember, do not want to rm "out.txt" since we are currently piping to it via 'tee'.
  rm -fr eclipse.platform.releng.aggregator/ eclipse.platform.releng.aggregator-master.zip eclipse.platform.releng.basebuilder-R38M6PlusRC3G/ getEBuilder.xml org.eclipse.releng.basebuilder/ runTests2.xml tempEBuilder/

  rm -fr production.properties propertiesAllFromRunTest2.properties sdk.tests streamSpecific-build.properties workarea

}

source localbuildproperties.shsource
#   Different versions of Ant are specified here in test script, just to confirm
#   nothing is specific to any recent version of ant. (Though, some of the machines
#   have ant 1.6 set as 'default'!)
#export ANT_HOME=/shared/common/apache-ant-1.7.1
export ANT_HOME=/shared/common/apache-ant-1.8.4/
#export ANT_HOME=/shared/common/apache-ant-1.9.2

#   JAVA_HOME is, at least, what runs the ant instance. If no 'jvm' option is specified,
#   it also becomes the instance that runs the tests.
#export JAVA_HOME=/shared/common/jdk1.5.0-latest
#export JAVA_HOME=/shared/common/jdk1.6.0-latest
#export JAVA_HOME=/shared/common/jdk1.7.0-latest
#export JAVA_HOME=/shared/common/jdk1.8.0_x64-latest
export JAVA_HOME=/shared/common/jdk1.7.0-latest
export WORKSPACE=/home/davidw/tempworkarea/
export PATH=${JAVA_HOME}/bin:${ANT_HOME}/bin:/usr/local/bin:/usr/bin:/bin:${HOME}/bin

# This variable signals parts of the script that we are testing the test scripts, 
# and should not actually start the tests.
export TESTING_TEST_XML=true

if [[ "$1" == "-c" ]]
then
  clean
fi

#    There are a number of test-<something> methods in test xml which, by convention, mean
#    to simply test the test script itself. The test-all target runs all of those tests.

# Note: currently this file always comes from master, no matter what branch is being built/tested.
wget -O getEBuilder.xml --no-verbose   http://davidw.com/c/platform/eclipse.platform.releng.aggregator.git/plain/production/testScripts/hudsonBootstrap/getEBuilder.xml 2>&1

# Can only test the "download form" if there is a current, accurate build. During development, should use git/master version.
# The getEBuilder.xml fill invoke "getBaseBuilder.xml" as well. 
# if that is not desired, set -DskipBaseBuilder=true
# ant -f getEBuilder.xml  -DskipBaseBuilder=true  -DdownloadURL=http://davidw.com/eclipse/downloads/drops4/M20140815-1230 -DEBUILDER_HASH=c287de2936649dba467d0f208b302be7136de6cc 
ant -f getEBuilder.xml  
#-DskipBaseBuilder=true 

ANTFILE=eclipse.platform.releng.aggregator/production/testScripts/runTests2.xml
buildId=M20140815-1230
eclipseStream=4.1.1
EBUILDER_HASH=c287de2936649dba467d0f208b302be7136de6cc

java -Djava.io.tmpdir=${WORKSPACE}/tmp -DDOWNLOAD_HOST=davidw.com -Xmx500m -jar $WORKSPACE/org.eclipse.releng.basebuilder/plugins/org.eclipse.equinox.launcher.jar  -DbuildId=$buildId -DeclipseStream=$eclipseStream -Dosgi.os=linux -Dosgi.ws=gtk -Dosgi.arch=x86_64 -DEBUILDER_HASH=${EBUILDER_HASH} -application org.eclipse.ant.core.antRunner -v -f ${ANTFILE} -Djava.io.tmpdir=${WORKSPACE}/tmp -DDOWNLOAD_HOST=davidw.com -Dtest.target=performance -DskipDerby=true

