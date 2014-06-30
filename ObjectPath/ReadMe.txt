
ObjectPath
==========

NSPathControl is a user interface control that represents a file system path or virtual path. "ObjectPath" is a Cocoa application that shows how you can use the many different features and aspects of NSPathControl, including the NSPathControlDelegate protocol.


About the Sample
----------------
"ObjectPath" illustrates the following:

1. Setting a file system path by clicking the "Set Path..." button.

2. Setting a custom path (with icons and specific URLs) by clicking the "Custom Path" checkbox.

3. Control's doubleAction
Sets the double action of this control so users can double-click a path component and reveal the file system object in the Finder.

4. Control Delegate Methods
Customizes the popup menu through the use of:
	- (void)pathControl:(NSPathControl*)pathControl willPopUpMenu:(NSMenu*)menu

Customizes the Open panel through the use of:
	- (void)pathControl:(NSPathControl*)pathControl willDisplayOpenPanel:(NSOpenPanel*)openPanel

5. Drag and Drop
Customizes drag and drop behaviors using the following:

To affect the user interface when a drop occurs by using:
	- (BOOL)pathControl:(NSPathControl*)pathControl acceptDrop:(id <NSDraggingInfo>)info
In this case, after a drop operation occurs the app updates its window, no longer requesting the user to drop something.

To control which file system object can be dragged from the control by using:
	-(BOOL)pathControl:(NSPathControl*)pathControl
		shouldDragPathComponentCell:(NSPathComponentCell*)pathComponentCell withPasteboard:(NSPasteboard*)pasteboard
In this case, volumes are arbitrarily chosen as objects you cannot drag.

To validate a drop operation on the control by using:
	- (NSDragOperation)pathControl:(NSPathControl*)pathControl validateDrop:(id <NSDraggingInfo>)info

