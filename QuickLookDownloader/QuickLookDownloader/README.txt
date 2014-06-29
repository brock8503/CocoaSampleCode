QuickLookDownloader

===========================================================================
About the Sample

QuickLookDownloader manages file downloads from the internet, displaying thumbnail images in the download list and high-detail previews using the QLPreviewPanel class.  This application demonstrates the two methods for displaying Quick Look content inside your application.

DownloadItem.m shows how to asynchronously get the Quick Look thumbnail for a file.

AppDelegate.m shows how to open and close the Quick Look panel. The standard menu shortcut for the Quick Look panel is ⌘-Y but the user should also be able to use the space key.

MyDocument.m shows how to control and provide the delegate and data source of the Quick Look panel.

DownloadsTableView.m subclasses NSTableView to handle the space key and open the Quick Look panel.

===========================================================================
Sample Requirements

Build requirements:
OS X 10.9 SDK

Runtime requirements:
OS X 10.7 or later

===========================================================================
Using the Sample

Enter the URL of a file that's capable of being previewed, e.g. http://developer.apple.com/documentation/UserExperience/Conceptual/AppleHIGuidelines/OSXHIGuidelines.pdf

Once the download is complete, observe how the standard document icon is replaced by a Quick Look thumbnail.
Select the file in the table and hit the space bar to show the document in the Quick Look preview panel.

===========================================================================
Further Reading

https://developer.apple.com/library/mac/documentation/Quartz/Reference/QLPreviewPanel_Class/Reference/Reference.html