#!/bin/bash

MODE="$1"
DEST_PATTERN="$2"
IMAGE_PATTERN="Pasted image"
TEMP_MD="/var/tmp/obsidian-rename-image.$$"

# IMAGES_PATH="./"
IMAGES_PATH="resources/"

[[ ! -z "$3" ]] && IMAGE_PATTERN="$3"
[[ -z "${IMAGE_PATTERN}" || -z "${DEST_PATTERN}" ]] && echo "Usage: $(basename $0) PREVIEW|RENAME <dest_pattern> (<image_pattern>)\nExample: $(basename $0) PREVIEW 'webcast_css_' 'Pasted image' " && exit 1
[[ "$MODE" != "PREVIEW" && "$MODE" != "RENAME" ]] && echo "Usage: $(basename $0) PREVIEW|RENAME <dest_pattern> (<image_pattern>)\nExample: $(basename $0) PREVIEW 'webcast_css_' 'Pasted image' " && exit 1

find . -name "*.md" > "$TEMP_MD"

INC=1
ls -1 "${IMAGES_PATH}${IMAGE_PATTERN}"* 2>/dev/null | sort -n | while read CURRENT_IMAGE ; do
  # For each image ...
  EXT="${CURRENT_IMAGE##*.}"
  CURRENT_IMAGE_BASENAME=$(basename "$CURRENT_IMAGE")
  
  echo "> Image [$CURRENT_IMAGE_BASENAME]"
  
  OK=1
  while [[ "$OK" -ne 0 ]] ; do
    [[ "${#INC}" -eq 2 ]] && I="0${INC}"
    [[ "${#INC}" -eq 1 ]] && I="00${INC}"
    TARGET_IMAGE="${IMAGES_PATH}${DEST_PATTERN}_${I}.${EXT}"
    OK=0
    [[ -f "${TARGET_IMAGE}" ]] && INC=$(expr $INC + 1) && OK=1
  done
  
  # Rename image  
  case "$MODE" in
    "PREVIEW")
      echo "  - Renaming image file [${CURRENT_IMAGE}] to [${TARGET_IMAGE}]"
      ;;
    "RENAME")
      mv "${CURRENT_IMAGE}" "${TARGET_IMAGE}"
      ;;
  esac

  # Markdown files
  # ![[Pasted image 3.png]]
  cat "$TEMP_MD" | while read MD_FILE ; do
    NB_OCC_IN_MD_FILE=$(grep "$CURRENT_IMAGE_BASENAME" "${MD_FILE}" | wc -l)
    if [[ "${NB_OCC_IN_MD_FILE}" -ne 0 ]] ; then
      case "$MODE" in
        "PREVIEW")
          echo "  - Rewriting markdown in [$MD_FILE] : '![[$CURRENT_IMAGE_BASENAME]]' to '![]($TARGET_IMAGE)'"
          ;;
        "RENAME")
          sed -i -e "s&!\[\[$CURRENT_IMAGE_BASENAME\]\]&![]($TARGET_IMAGE)&g" "${MD_FILE}"
          ;;
      esac
    fi 
  done
  
  echo ""
  
  INC=$(expr $INC + 1)
done

rm -f "$TEMP_MD" >/dev/null 2>&1 
