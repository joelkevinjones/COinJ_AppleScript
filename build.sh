# Compile and install scripts in all subdirectories into 
# ~/Library/Scripts/Applications
SRCDIR=`dirname "$0"`
#INSTALL_DIR=`dirname "$0"`/Applications
INSTALL_DIR=~/Library/Scripts/Applications
mkdir -p "${INSTALL_DIR}"
find "${SRCDIR}" -name '*\.applescript' -and -not -path '*URLHandlers*' -and -not -path '*PalmDesktop*' -print0 |
while IFS= read -r -d '' f
do
  # make directory in INSTALL_DIR that is the same relative directory as
  # f is to SRC_DIR
  newDir=`dirname "$INSTALL_DIR/${f/$SRCDIR}"`
  mkdir -p "${newDir}"
  srcName=`basename "${f}"`; appName="${srcName/.applescript}.scpt"
  # compile src directly into INSTALL_DIR
  osacompile -o "${newDir}/${appName}" "${f}"
done
