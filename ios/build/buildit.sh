#!/bin/bash
#
# Build foobar iOS native app
#
# n: train_name
# d: train_display_name
# t: type 

#######################################
# NOTE: removed password and profiles 
#######################################
usage="
  $(basename $0) [-h]  
	[-n TRAIN_NAME]
	[-d TRAIN_DISPLAY_NAME]
	[-t TYPE]: {Dogfood, Production}
"

while getopts ':hn:d:t:' option; do
  case "$option" in
    h)  echo "$usage"
        exit
        ;;
    n)  TRAIN_NAME=$OPTARG
        ;;
    d)  TRAIN_DISPLAY_NAME=$OPTARG
        ;;
    t)  TYPE=$OPTARG
        ;;
    ?)  printf "illegal option: '%s'\n" "$OPTARG" >&2
        echo "$usage" >&2
        ;;
  esac
done
shift $((OPTIND -1))

printf "
HOME: $HOME
WORKSPACE: $WORKSPACE

TRAIN_NAME: $TRAIN_NAME
TRAIN_DISPLAY_NAME: $TRAIN_DISPLAY_NAME
TYPE: $TYPE
"

###################
dogfood_build() {

  mkdir -p  buildResults/Dogfood 
  /usr/bin/xcodebuild -alltargets clean
  /usr/bin/xcodebuild -scheme Enterprise  -configuration 'Enterprise (Release)' -sdk iphoneos DSTROOT=buildResults/Dogfood DWARF_DSYM_FOLDER_PATH=buildResults/Dogfood  DEPLOYMENT_LOCATION=YES build
  
  # package and sign the build
  cd "$WORKSPACE/foobar/buildResults/Dogfood/Applications"
  /usr/bin/xcrun -sdk iphoneos PackageApplication -v foobar.app --sign 'iPhone Distribution: foobar' --embed /Users/jenkins/Library/MobileDevice/Provisioning\ Profiles/<insert_profile_here>.mobileprovision -o "$WORKSPACE/foobar/buildResults/Dogfood/foobar.ipa"

}

###################
production_build() {

  mkdir -p  buildResults/Production 
  /usr/bin/xcodebuild -alltargets clean
  /usr/bin/xcodebuild -scheme Production  -target foobar -configuration 'Production (Release)' -sdk iphoneos DSTROOT=buildResults/Production DWARF_DSYM_FOLDER_PATH=buildResults/Production  DEPLOYMENT_LOCATION=YES  build
  
  cd "$WORKSPACE/foobar/buildResults/Production/Applications"
  /usr/bin/xcrun -sdk iphoneos PackageApplication -v foobar.app --sign "iPhone Distribution: foobar, Inc." --embed /Users/jenkins/Library/MobileDevice/Provisioning\ Profiles/<insert_profile_here>.mobileprovision -o "$WORKSPACE/foobar/buildResults/Production/foobar.ipa"

}


###################
#
# TRAIN_NAME shows in Settings -> About -> Version
# TRAIN_DISPLAY_NAME shows as the app name on home screen
#  
export TRAIN_NAME=$TRAIN_NAME
export TRAIN_DISPLAY_NAME=$TRAIN_DISPLAY_NAME

# unlock the iOS keychain so that the codesign util can run headless without user interaction
security unlock-keychain -p <insert_password_here>  $HOME/Library/Keychains/iOS.keychain

# build baby
rm -rf ~/Library/Developer/Xcode/DerivedData/foobar-*/
cd $WORKSPACE
git clean -df
cd $WORKSPACE/foobar

if [[ $TYPE == "Dogfood" ]]; then

  printf "***** Doing $TYPE build"
  dogfood_build

elif [[ $TYPE == 'Production' ]]; then
  
  printf "***** Doing $TYPE build"
  production_build

fi

exit

