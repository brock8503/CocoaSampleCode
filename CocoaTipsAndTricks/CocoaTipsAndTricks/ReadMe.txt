### Cocoa Tips and Tricks ###

===========================================================================
DESCRIPTION:

Contains seven sample projects covering various Cocoa tips and tricks.

BlurryView:
Demonstrates how to pixel align NSViews and to show proper HiDPI support.

ExceptionReporting:
Demonstrates how to show a customized exception reporting user interface.
This lets the user know when the exception happens in order to possibly prevent
subsequent random crashes that are difficult to debug.

NibLoading:
Demonstrates how to use NSNib class for loading nib files and instantiating
(copying) top-level nib objects from them.

StaticObjcMethods:
Demonstrates how to use static Objective-C methods for easy access to class ivars.
Make sure to check the Console log to see the reporting of the ivar value changes.

TableViewLinks:
Demonstrates how to use hyperlinks inside an NSTableView cell.

TableViewVariableRowHeights:
Demonstrates how to implement "variable row height" sizes in NSTableView.

UsingBlocksAsContextInfo:
Demonstrates how to implement Objective-C "blocks" passed in as the 'contextInfo'
to NSAlert, helping to handle the alert result.


===========================================================================
BUILD REQUIREMENTS:

OS X 10.8 SDK or later

===========================================================================
RUNTIME REQUIREMENTS:

OS X v10.7 or later

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.1 - Upgraded base SDK to OS X 10.8, now using Automatic Reference Counting (ARC)
1.0 - First version.

===========================================================================
Copyright (C) 2010-2013 Apple Inc. All rights reserved.
