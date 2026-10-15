#!/bin/sh
set -eu

INFO_PLIST_NAME="GoogleService-Info.plist"
FIREBASE_ROOT="${PROJECT_DIR}/${TARGET_NAME}/Resources/Firebase"

FOLDER="Keeper"
case "${CONFIGURATION}" in
  KeeperDevDebug|KeeperDevRelease)
    FOLDER="KeeperDev"
    ;;
  KeeperUKDebug|KeeperUKRelease)
    FOLDER="KeeperUK"
    ;;
esac

SOURCE_PLIST="${FIREBASE_ROOT}/${FOLDER}/${INFO_PLIST_NAME}"
DEFAULT_PLIST="${FIREBASE_ROOT}/Keeper/${INFO_PLIST_NAME}"
DESTINATION_DIR="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
DESTINATION_PLIST="${DESTINATION_DIR}/${INFO_PLIST_NAME}"

if [ ! -f "${SOURCE_PLIST}" ]; then
  if [ "${FOLDER}" = "KeeperUK" ] && [ -f "${DEFAULT_PLIST}" ]; then
    echo "Firebase plist for ${FOLDER} is missing, fallback to Keeper"
    SOURCE_PLIST="${DEFAULT_PLIST}"
  else
    # Demo mode: Firebase is never configured, so the app builds and runs without this plist.
    echo "Firebase plist not found, skipping: ${SOURCE_PLIST}"
    exit 0
  fi
fi

mkdir -p "${DESTINATION_DIR}"
cp "${SOURCE_PLIST}" "${DESTINATION_PLIST}"
echo "Copied ${SOURCE_PLIST} -> ${DESTINATION_PLIST}"
