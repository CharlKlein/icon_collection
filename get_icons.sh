#!/bin/bash

# This script downloads the images from the given url and stores them in the given directory

rm -rf images

mkdir -p images/gcp images/k8s images/azure images/cncf/projects images/cncf/other

# Download GCP icons
wget https://cloud.google.com/static/icons/files/google-cloud-icons.zip
unzip google-cloud-icons.zip -d images/gcp

# move all svgs to root
find images/gcp -mindepth 2 -type f -name "*.svg" -print -exec mv {} images/gcp \;

#cleanup pngs
find images/gcp -type f -name "*.png" -delete

#cleanup directories
find images/gcp -type d -delete
rm google-cloud-icons.zip

# Download Kubernetes icons
git clone https://github.com/kubernetes/community
mv community/icons/svg/* images/k8s
rm -rf community

#download cncf icons
git clone https://github.com/cncf/artwork.git
mv artwork/projects/* images/cncf/projects
mv artwork/other/* images/cncf/other
rm -rf artwork

find images/cncf -type f -name "*.png" -delete
find images/cncf -type f -name "*.lnk" -delete
find images/cncf -type f -name "*.pdf" -delete

#download azure icons
wget  https://arch-center.azureedge.net/icons/Azure_Public_Service_Icons_V15.zip
unzip Azure_Public_Service_Icons_V15.zip -d images/azure
rm Azure_Public_Service_Icons_V15.zip

#move all svgs to images base
mv images/azure/Azure_Public_Service_Icons/Icons/* images/azure
rm -rf images/azure/Azure_Public_Service_Icons

#remove + from foldernames
find images/azure -type d -name "*\+*" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f//+/}")"; done

#remove double spaces from foldernames
find images/azure -type d -name "*\ \ *" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done

#cleanup foldername with special characters
find images/azure -type d -name "*\ *" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f// /_}")"; done

#replace __ with _ from foldernames
find images/azure -type d -name "*__*" -print0 | sort -rz | while read -d $'\0' f; do mv -v "$f" "$(dirname "$f")/$(basename "${f//__/_}")"; done


export listofimages=$(find images/azure -mindepth 2 -type f -name "*.svg")

for base_file in $listofimages
do
    echo $base_file
    mv -v $base_file "$(echo $base_file | sed -E 's/[0-9]{0,5}-icon-service-//')"
done

git add *
git commit -am "update icons"
git push