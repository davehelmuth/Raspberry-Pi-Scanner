#!/bin/bash


MakePDF () {

     #Get the document name and page number, which would have been passed to this function.
     documentName=$1
     Number_of_Files=$2

     # The directory where I've chosen to store the image fles
     directory='/home/pi/Documents/'

     # Will hold the file locations (the file path) and the file names as a string
     files=''

     # The first file name will always end in a zero
     i=0
     while [ $i -lt $Number_of_Files ]
     do
          # After the 1st iteration of loop, files will hold "/home/pi/Documents/FileName0.ppm " followed by a space
	  # the space is used as seperator for successive file paths
	  # After 2nd iteration of loop, files will hold "/home/pi/Documents/FileName0.ppm /home/pi/Documents/FileName1.ppm "
	  # And so on . . . 
	  files=$files$directory$documentName$i$'.ppm '
	  
	  # increment page number
          i=$[$i+1]
     done

     #trim that blank space that was left at the end of the last string
     files=${files::-1}

     #Make a multipage pdf document from our images
     convert -density 300 $files -compress JPEG $documentName$'.pdf'
 
     #Delete all the scanned images
     rm $directory*.ppm
     

}


Scanpage () {
     echo "Running sane software..."
     
     # Combine the document name with the page number ($1 is the document name, where $2 is the page number)
     # $1 and $2 are the function parameters
     documentName=$1$2

     # Note if the page being scanned is the 1st page, it will have a page number of ZERO

     #Next: Take the document name, File extension, and directory path as a string. Aftwards Convert the strings to the appropriate file paths below
     directory='/home/pi/Documents/'

     #Will hold file path, document name followed by the page number
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


#Bring up Document name dialog box 
exitstatus=$?
if [ $exitstatus = 0 ]; then
    
    #Replace any spaces in the document name with an underscore
    DocName=${DocName// /_}
    
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

             #tally (Increment page number)
             ((ScanTally++))
        
        else
             echo "No"
	     #Since the User doesn't want to scan more pages

             #Generate PDF from scanned image
             MakePDF $DocName $ScanTally

             #exit the script
             exit
        fi
    done
else
    echo "You chose Cancel." 
    exit
fi

