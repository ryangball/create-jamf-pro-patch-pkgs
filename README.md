# Create Jamf Pro Patch PKGs
Easily package Jamf Pro applications individually to be used with Jamf Pro's Patch Management.

### Explanation
Patch Management within Jamf Pro requires individual applications when patching the Jamf Pro tools (Jamf Admin, Jamf Remote, Jamf Imaging, Composer, Recon). Creating these indivudual packages can be tedious and sometimes they require special permissions.

This script will take whatever version of Jamf Pro tools installed on a Mac and package them up individually and reveal the packages in Finder.

### Features
- Creates individual packages for each Jamf Pro component app (Jamf Admin.app, Jamf Imaging.app, Jamf Remote.app, Composer.app, and Recon.app)
- When one of the packages is istalled, the corresponding Casper Suite app will be removed
- Disable the automatic relocation of the Jamf apps to the `/Applications/Casper\ Suite` directory
- Fix permissions you usually get when packaging with Composer.app where icons don't show up for an installed Jamf app
- Allows for specifying whether or not non-admins can execute the applications

![alt text](/images/packaged_preview.png)

### Restrict Non-Admins from Executing
If you want only admins to read/execute the resulting installed application you can change `allowNonAdminToReadOrExecute="true"` to `allowNonAdminToReadOrExecute="false"`.
