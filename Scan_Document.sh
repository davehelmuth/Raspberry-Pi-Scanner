#!/bin/bash

#Clear out any old scanned images


MakePDF () {

     echo "PDF fuction started"

     #Get the document name, which would have been passed to this function.
     documentName=$1
     Number_of_Files=$2

     echo $documentName
     echo $Number_of_Files
     
     directory='/home/pi/Documents/'

     #holds each file path for each image file
     files=''

     i=0
     echo $i
     while [ $i -lt $Number_of_Files ]
     do
          files=$files$directory$documentName$i$'.ppm ' 
          echo $files 
          i=$[$i+1]
     done
     echo "The file string"
     echo $files
     #trim that blank space that was left at the end of the string
     files=${files::-1}

     convert -density 300 $files -compress JPEG $documentName$'.pdf'
 
     #Delete all the scanned images
     rm $directory*.ppm
     

}


Scanpage () {
     echo "Running sane software..."
     
     #Combine the document name with the page number ($1 is the document name, where $2 is the page number)
     documentName=$1$2


     #Next: Take the document name, File extension, and directory path as a string. Aftwards Convert the strings to the appropriate file paths below
     
     directory='/home/pi/Documents/'

     picture_filepath=$directory$documentName$'.ppm'

     #Scan the document
     scanimage -d 'pixma:04A91712_14799B' --resolution 300 -x 2550 -y 3300 > $picture_filepath
     wait
     

}

clear

#The total number of sheets scanned at this point is zero
ScanTally=0

#Get the name of the document
DocName=$(whiptail --title "Scan Document" --inputbox "Please name the document." 10 60 Scanned_Page 3>&1 1>&2 2>&3)

#Replace any spaces in the document name with an underscore
DocName=${DocName// /_}

 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "The name of your document is:" $DocName

    #Scan Document code here (Run the function Scanpage)
    Scanpage $DocName $ScanTally

    #Tally the scan (We need to keep track of how many pages have been scanned, so we can later label each scanned image with a page number)
    ((ScanTally++))   


    while :
    do
       #Do we want to scan another page: If no, make pdf and then exit program, If yes Scan another page
       if (whiptail --title "Scan another page?" --yes-button "Yes" --no-button "No"  --yesno "If yes, Insert a new page, and select Yes" 10 60) then
    	     echo "Yes"
	     #Scan Document code here, and then tally the scan
             Scanpage $DocName $ScanTally

             #tally
             ((ScanTally++))
        
        else
             echo "No"
	     #Since the User doesn't want to scan more pages

             #Generate PDF from scanned images
       
             MakePDF $DocName $ScanTally

             exit
        fi
    done
else
    echo "You chose Cancel."
    exit
fi

