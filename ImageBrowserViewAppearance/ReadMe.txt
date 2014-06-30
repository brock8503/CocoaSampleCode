ImageBrowserAppearance

This sample shows how to customize the appearance of the IKImageBrowserView.

Usual steps to customize the appearance of the image browser :

1) configure the view
    The IKImageBrowserView class allows you to:

	- set the font of the titles / subtitles
	- set the inter cell spacing
	- set the size of the cells
	- set the background color
	- set the selection color
	- set a background layer
	- set a foreground layer

2) implement your own cell
   Subclass the IKImageBrowserView and implement newCellForRepresentedItem:.
   In this method, return an instance of your own subclass of IKImageBrowserCell.
   In you subclass of IKImageBrowserCell, override some of the following methods to modify the layout:
	
	- (NSRect) imageContainerFrame; 
	- (NSRect) imageFrame; 
	- (NSRect) selectionFrame;
	- (NSRect) titleFrame;
	- (NSRect) subtitleFrame;	
	- (NSImageAlignment) imageAlignment; 

  In you subclass of IKImageBrowserCell, override some of the following methods to modify the appearance:

	- (CGFloat) opacity;
	- (CALayer *) layerForType:(NSString *) type;
	

Changes from Previous Versions
1.1 - Update for latest Xcode. Replaced deprecated APIs.
1.0 - First version

Feedback and Bug Reports
Please send all feedback about this sample to:
<http://developer.apple.com/contact/feedback.html>

Please submit any bug reports about this sample to:
<http://developer.apple.com/bugreporter>