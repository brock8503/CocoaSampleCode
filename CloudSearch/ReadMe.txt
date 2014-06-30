### CloudSearch ###

===========================================================================
DESCRIPTION:

Demonstrates how to find documents in iCloud, using NSMetaDataQuery.

Included as part of this sample is a class called "CloudDocumentsController" which runs Spotlight queries, using NSMetaDataQuery, to discoved files found in iCloud.  You can use this class to quickly gain access to those available files.


===========================================================================
SETTING UP MAC AND YOUR XCODE PROJECT:
 
Configuring your Xcode project and your Mac require a few steps in the OS X Provisioning Portal and in Xcode:

1) Configure your Mac:
Each Mac you plan to test needs to have an iCloud account.  This is done by creating or using an existing Apple ID account that supports iCloud.  You can do this directly on the device by opening System Preferences, and selecting iCloud.  Each Mac needs to be configured with this account.
 
2) Configure your Provisioning Profile:
You will need to visit the Developer Certificate Utility page to create a new development provisioning profile <https://developer.apple.com/certificates/index.action>.  This involves creating a new App ID to include iCloud support. iCloud requires an Explicit App ID (non-wildcard). After creating the App ID verify iCloud shows as Enabled on the Manage Tab, and click 'Configure' to enable iCloud if necessary.
 
After creating a new development provisioning profile, download and install the iCloud development provisioning profile by dragging it to the Xcode icon in the Dock. 
 
3) Xcode project Entitlements:
An entitlements file in this sample project includes the key "com.apple.developer.ubiquity-container-identifiers".  For your own app you will need to use a different value to match your Team ID (or company/organization ID). Your Team ID is shown on the member center website <https://developer.apple.com/membercenter/index.action#accountSummary>. See the Program Membership section on the "Your Account" tab.   
 
You can include more than one container if you wish. For example this sample currently has for its container identifier:
 
$(TeamIdentifierPrefix)com.yourcompany.cloudsearch
 
where $(TeamIdentifierPrefix) is the Team ID found in the Provisioning Portal, and the rest is followed by your app's bundle identifier.
 
4) The bundle identifier defined on your Xcode project's Target > Info tab needs to match the App ID in the iCloud provisioning profile. This will allow you to assign the new profile to your Debug > Code Signing Identities in your Xcode project Target > Build Settings. 
 
So if your provisioning profile's App ID is "<your TeamID>.com.yourcompany.cloudsearch", then the bundle identifier of your app must be "com.yourcompany.cloudsearch".
 
5) Set your "Code Signing" identity in your Xcode project to match your particular App ID.


===========================================================================
BUILD REQUIREMENTS:

Xcode 4.6.x, OS X SDK 10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

OS X 10.8 or later

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2013 Apple Inc. All rights reserved.
