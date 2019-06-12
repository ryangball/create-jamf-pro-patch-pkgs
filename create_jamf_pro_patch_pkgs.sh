#!/bin/bash
# Written by Ryan Ball

tempDir="/private/tmp/jamfpro"
# The below variable can be set to false to restrict non-admin users from reading or executing the application
# Otherwise you can leave blank or set to true to allow all users to read and execute the application
allowNonAdminToReadOrExecute="false"

applications=(
    "Jamf Admin"
    "Jamf Remote"
    "Jamf Imaging"
    "Recon"
    "Composer"
)

# Make sure we run as root so we can chown to root:admin
if [[ "$EUID" -ne 0 ]]; then
  echo "Please run as root with sudo."
  echo "Example: sudo sh $(basename "$0")"
  echo "Example: sudo ./$(basename "$0")"
  exit 0
fi

# Loop through the applications array to package each Jamf Pro app individually
for application in "${applications[@]}"; do
    # If the Jamf Pro app does not exist on the system we are building the packages on, skip it and move on to the next one
    if [[ ! -e "/Applications/Jamf Pro/$application.app" ]]; then
        echo "Error, $application.app does not exist at /Applications/Jamf Pro/$application.app; skipping."
        continue
    fi
    identifier=$(defaults read "/Applications/Jamf Pro/$application.app/Contents/Info.plist" CFBundleIdentifier)
    version=$(defaults read "/Applications/Jamf Pro/$application.app/Contents/Info.plist" CFBundleShortVersionString)
    workingDir="$tempDir/$application"
    oldAppName=${application/Jamf/Casper}

    mkdir -p "$workingDir/files"
    mkdir -p "$workingDir/scripts"
    mkdir -p "$tempDir/build"

    echo "Staging $application.app for packaging..."
    rsync -aE "/Applications/Jamf Pro" "$workingDir/files/" --include "$application.app" --exclude '*.app'

# # Create the preinstall script for the PKG to ensure that Casper Suite app counterparts are removed
cat << EOF > "$workingDir/scripts/preinstall"
#!/bin/bash

/bin/rm -Rf "/Applications/Casper Suite/$oldAppName.app"

appsRemain=\$(/usr/bin/find "/Applications/Casper Suite" -name "*.app")
if [[ -z "\$appsRemain" ]]; then
    /bin/rm -Rf "/Applications/Casper Suite"
fi

exit 0
EOF

# Create the PKG Component Plist to ensure that new Jamf Pro apps are not installed in place of the Casper Suite apps
cat << EOF > "$workingDir/${application}_Component.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
  <dict>
    <key>BundleIsRelocatable</key>
    <false/>
    <key>BundleIsVersionChecked</key>
    <false/>
    <key>BundleOverwriteAction</key>
    <string>upgrade</string>
    <key>RootRelativeBundlePath</key>
    <string>/Jamf Pro/$application.app</string>
  </dict>
</array>
</plist>
EOF

    # Set permissions on files
    chown -R root:admin "$workingDir/files/Jamf Pro"
    if [[ "$allowNonAdminToReadOrExecute" == "false" ]]; then
        echo "Setting permissions to restrict non-admin users from reading and executing $application.app."
        chmod -R 750 "$workingDir/files/Jamf Pro"
    else
        echo "Setting permissions to allow non-admin users to read and execute $application.app."
        chmod -R 755 "$workingDir/files/Jamf Pro"
    fi
    chmod +x "$workingDir/scripts/preinstall"

    # Create the package
    echo "Packaging $identifier version $version..."
    pkgbuild --quiet --root "$workingDir/files/" \
        --component-plist "$workingDir/${application}_Component.plist" \
        --install-location "/Applications/" \
        --scripts "$workingDir/scripts/" \
        --identifier "$identifier" \
        --version "$version" \
        --ownership preserve \
        "$tempDir/build/JamfPro-${application}_${version}.pkg"

    echo " "
done

open "$tempDir/build" &>/dev/null

exit 0
