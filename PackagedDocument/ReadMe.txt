### PackagedDocument ###

===========================================================================
DESCRIPTION:

"PackagedDocument" is a text editing application for opening, editing and saving packaged documents to iCloud using NSDocument and NSFileWrapper. This sample is ARC-enabled (Automatic Reference Counting).

File Format and NSFileWrapper:
Choices you make in designing your document format can impact network transfer performance to and from iCloud for your app’s documents. The most important choice is to be sure to use a file package for your document format.  If your document data format consists of multiple distinct pieces, use a file package for your document file format. A file package, which you access by way of an NSFileWrapper object, lets you store the elements of a document as individual files and folders that can be read and written separately—while still appearing to the user as a single file. The iCloud upload and download machinery makes use of this factoring of content within a file package; only changed elements are uploaded or downloaded.

Three distinctive components of the document format:
This sample demonstrates the use of NSFileWrapper by writing three distinctive files: text, image and plist files.
Each document window allows the user to add text and an image.  The plist file is used as an internal metadata file used to hold misc information about that document, in particular the disclosure state of the image section of the window.  It writes and reads the plist file using NSPropertyListSerialization.


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
 
$(TeamIdentifierPrefix)com.yourcompany.PackagedDocument
 
where $(TeamIdentifierPrefix) is the Team ID found in the Provisioning Portal, and the rest is followed by your app's bundle identifier.
 
4) The bundle identifier defined on your Xcode project's Target > Info tab needs to match the App ID in the iCloud provisioning profile. This will allow you to assign the new profile to your Debug > Code Signing Identities in your Xcode project Target > Build Settings. 
 
So if your provisioning profile's App ID is "<your TeamID>.com.yourcompany.PackagedDocument", then the bundle identifier of your app must be "com.yourcompany.PackagedDocument".
 
5) Set your "Code Signing" identity in your Xcode project to match your particular App ID.


===========================================================================
BUILD REQUIREMENTS:

Xcode 4.6 or later, OS X 10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

OS X 10.8 or later

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.1 - Minor changes for clarity, updated to adopt current best practices for Objective-C.
1.0 - First version.

===========================================================================
Copyright (C) 2012-2013 Apple Inc. All rights reserved.
