#!/bin/sh

if [ $PWD = /home/luizperciliano/metamap-portugues/metamap/public_mm ]; then
  echo "You can't run this in the MetaMap base directory: /home/luizperciliano/metamap-portugues/metamap/public_mm"
  echo "Please run this from a directory outside of the base directory"
fi

CHOICE=no

read -p "Do you really want to uninstall MetaMap? [no/yes] " CHOICE
if [ "$CHOICE" = "" ]; then
   CHOICE=no
fi     
if [ "$CHOICE" = "no" ]; then
  echo "Aborting uninstall."
  exit 0
fi

echo "Removing Tagger Server"
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm/MedPost-SKR
echo "Removing WSD Server"
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm/WSD_Server
echo "Removing Lexicon"
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm/lexicon
echo "Removing MetaMap Databases"
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm/DB
echo "Removing Programs"
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm/bin
echo "Removing Base Directory"
cd /home/luizperciliano/metamap-portugues/metamap/public_mm/..
rm -rf /home/luizperciliano/metamap-portugues/metamap/public_mm

if [ -e /home/luizperciliano/metamap-portugues/metamap/public_mm ]; then
    echo "Error: MetaMap installation not fully removed!!"
else
    echo "Removal of MetaMap installation successful."
fi
exit 0





