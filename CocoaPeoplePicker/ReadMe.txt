CocoaPeoplePicker

This sample demonstrates how to use AddressBook's ABPeoplePickerView class. It embeds an ABPeoplePickerView object in a window, which includes controls for view options and access to data the user has selected.

This sample also shows how to:
-Integrate the People Picker view into a Cocoa application using Interface Builder.
-Display the current user's address book (groups and contacts).
-Allow group selections and multiple selections at a time.
-Perform actions such as showing information about selected records or groups and selecting and editing records from the user's address book.
-Display a user's selected properties. 


Build requirements
OS X 10.8 or later

Runtime requirements
OS X 10.7 or later


Using the Sample
The application displays a People Picker view filled with details from the logged-in user address book. The picker contains the Properties, Selection, and Actions panes. Use the Properties pane to display this user's phone, address, email, Aim, and homepage information. Use the Selection pane to perform group selection or multiple selections. Use the Action pane to perform tasks from within the address book.



Change from Previous Versions
1.3 -Updated to adopt current best practices for Objective-C, replaced deprecated kABAIMInstantProperty and kABHomePageProperty APIs, and now supports sandboxing. You may encounter a "[NSImage compositeToPoint:operation:] is deprecated in MacOSX 10.8 and later. Please use -[NSImage drawAtPoint:fromRect:operation:fraction:] instead." message when launching this sample. This is a known bug that does not affect running this sample.
1.2 -Updated for Xcode 3.0 and later.
1.1 -Updated for OS X 10.6.
1.0 -First Release


Copyright (C) 2002-2013 Apple Inc. All rights reserved.