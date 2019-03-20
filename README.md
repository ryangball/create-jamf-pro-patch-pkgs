# Create Jamf Pro Patch PKGs
Easily package Jamf Pro applications individually to be used with Jamf Pro's Patch Management.

## Explanation
Patch Management within Jamf Pro requires individual applications when patching the Jamf Pro tools (Jamf Admin, Jamf Remote, Jamf Imaging, Composer, Recon). Creating these indivudual packages can be tedious and sometimes they require special permissions.

This script will take whatever version of Jamf Pro tools installed on a Mac and package them up individually and reveal the packages in Finder.

![alt text](/images/packaged_preview.png)

## Restrict Non-Admins from Executing
If you want only admins to read/execute the resulting installed application you can change `allowNonAdminToReadOrExecute="true"` to `allowNonAdminToReadOrExecute="false"`.
