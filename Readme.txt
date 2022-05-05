======================================================
	J2k2PdfDerivativeGenerationPlugin - Rosetta Plugin for Archives NZ
======================================================
Description	: The purpose of the plugin is to generate a
		  single multi-page PDF file from multiple
		  JPEG 2000 images

Author		: Mathachan Kulathinal
Date		: 15.Sep.2015


Replace all `<path>` to real software path in `src/main/bin/J2k2PdfDerivativeGeneration.sh` (Line 28, 32, 34)




Step 1:
Convert the JPEG 2000 files to HIGH-RES JPEG files using j2kdriver.
If the j2kdriver fails to convert the jp2 file, then use ImageMagick
to convert the jp2 file to high-res jpeg

Step 2:
Convert the High-Res jpeg files to Low-Res jpeg files using ImageMagick
and the conversion arguments

Step 3:
Generate individual PDF files from the low-res jpeg file using sam2p

Step 4:
Generate the single PDF files from the individual pdf files using
sejda merge function

Plugin invoke command from Rosetta Stream Handlers
<jpeg conversion parameters> <output pdf label> <input dir> <output dir>

Ex: -compress JPEG -blur 1x0.5 -quality 92 -resize '900>' pdf_dc /tmp/inputfile /tmp/outputfile


NOTE:
sam2p for linux can be downloaded as a tar.gz file
where as for SUN-Solaris, it needs to be build from source

Use the Rosetta Admin UI to install the plugin


INITIAL ISSUES:
There was trouble running the sejda due to a JVM error complaining about
invalid initial heap size setting -Xms3000mm. This value was set in
global.properties and wrapper.conf within Rosetta for the minmemory
value. This value was changed to have only the integer without the
"m" at the end. After changing the global.properties, the set-globals.sh
script had to be run after stopping rosetta service.

RUN as any login user

PATH=<path>/java/bin:<path>/product/bin:/bin:/etc:/usr/bin:/usr/local/bin:/usr/bin/X11:<path>/oracle/product/11.2.0.3/bin:<path>/util:$PATH
export PATH
LD_LIBRARY_PATH=<path>/perl/lib:<path>/im/lib:<path>/jpeg2000/sdk/linux-x86-64/lib:<path>/openssl/lib:/usr/lib:/usr/local/lib:/lib:<path>/openssl/lib:<path>>/oracle/product/11.2.0.3/lib
export LD_LIBRARY_PATH
./J2k2PdfDerivativeGeneration.sh -compress JPEG -blur 1x0.5 -quality 92 -resize '900>' pdf_derivative_copy <path>/jp2files <path>/pdffile
