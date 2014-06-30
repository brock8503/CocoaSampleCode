### Cocoa Slides ###

================================================================================
DESCRIPTION:

"Cocoa Slides" illustrates the use of the new animation API and optional layer-backed view rendering model that are being added to AppKit in Leopard.  The use of Core Animation CALayers to cache prerendered content on a per-view basis facilitates high-performance animations and Core Image-based visual effects, as this sample application demonstrates.  It was demonstrated as part of the WWDC 2006 Session 132 - "Cocoa Animation Techniques"


Usage

When launched, Cocoa Slides opens an image browser window that displays thumbnails of the images in a default folder.  (First it looks for "~/Pictures/All Desktop Images", then falls back to "/Library/Desktop Pictures/Nature" if such a folder doesn't exist.)  Other folders of images can be browsed using the "File" -> "Open..." menu command.


================================================================================
IMPLEMENTATION:

To help clarify the division of functionality in this example, the enclosed Xcode project file has its source files organized into "Model", "View", "Controller", and "Support" groups.  "Support" files provide generally useful extensions to existing AppKit classes, while the remaining groups reflect the Model-View-Controller structure of the Cocoa Slides application.

Inside the browser window's AssetCollectionView, each image is visually represented by a small view subtree, consisting of a SlideCarrierView at the root, which contains a SlideImageView, a checkbox-style NSButton, and two NSTextFields as its subviews.  Using the various controls provided at the bottom of the window, the slides can be arranged in various layouts, and sorted according to various properties of the image files that they represent.  (Currently the sorting only affects layout order, not the back-to-front order of the slides.)  When the animation interval is set to a nonzero value, the changes in layout and sorting will be animated instead of taking effect immediately.

In examining the source code, note that the vast majority of it has nothing in particular to do with animation.  For example, the code that implements the various slide layouts (located in ViewLayout.m) believes that it is dealing directly with views, and computing and setting their frame origins and rotations with immediate results.  All that's needed to harness the same code to effect animation of the views to their new positions and orientations, instead of immediately moving them, is to pass these layout methods an array of "animtor" proxy objects for the subviews, instead of the subviews themselves.  This is done in AssetCollectionView's -layoutSubviews method.  The duration of the implicit animation that this initiates can be controlled by wrapping this activity in an NSAnimationContext -beginGrouping / -endGrouping pair, setting the duration for the current animation context within the grouping, as -layoutSubviews does.

Each slide has a checkbox that can be used to select the slide for display in a slideshow with transition effects.  Clicking the "Slideshow" button in the lower-right corner of the browser window brings up a slideshow window containing a SlideshowView, which advances from one slide to another by simply replacing one NSImageView with another, via the -replaceSubview:with: NSView method (see -transitionToImage: in SlideshowView.m).  Because the containing SlideshowView instance associates an CATransition animation with the "subviews" key in its animations dictionary (see the -setAnimations: message sent at the end of -updateSubviewsTransition in SlideshowView.m), the resultant change in the subviews array triggers a visual transition effect.

Clicking on any of the slides demonstrates the use of a Core Image filter to apply a visual effect to view content, by simply setting the view's "contentFilters" property.  The effect is applied immediately on mouse down, but faded out with a brief animation on mouse up.  All of this is accomplished using very little code, as you can see in SlideCarrierView's -doHighlightEffect: method.

Toggling the "Shadows" checkbox demonstrates the use of the new "shadow" property of NSView, by adding a shadow to each slide's SlideCarrierView.  Rendering a shadow for every slide has some performance cost, and may slow the animation framerate; toggling shadows off speeds up animation again.  As with the filter properties (contentFilters, backgroundFilters, and compositingFilter) and the new alphaValue property, setting a view's shadow only has a visible effect in layer-backed view compositing mode.  Under conventional view rendering, settings for these properties are remembered, but do not affect display.

Toggling the "QC Background" checkbox demonstrates the ability of Core Animation layer trees to allow other content to be composited over Quartz Composer content. This is accomplished by substituting a QCCompositionLayer in place of the layer that AppKit would otherwise automatically create and manage for the AssetCollectionView, via NSView's -setLayer: method.  Note that with the exception of the few lines of code required to insert the Quartz Composer content (in AssetCollectionView's -setUsesQuartzCompositionBackground: method), and the uses of -setWantsLayer: in BrowserWindowController's -windowDidLoad method to activate layer-backed view rendering for the AssetCollectionView and SlideshowView and their descendants, no other part of the Cocoa Slides code is concerned with the fact that views are being mirrored into layers.  All of this is managed by AppKit automatically.

================================================================================
BUILD REQUIREMENTS:

OS X 10.8 SDK or later

================================================================================
RUNTIME REQUIREMENTS:

OS X 10.7 or later


================================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.5 - Upgrade to OS X 10.8 SDK, no longer searches for pictures without user interfaction (for sandboxing), replaced various deprecated NSFileManager APIs, remove some memory leaks.

1.4 - fixed leak of previous currentImageView in SlideshowView's -transitionToImage: method
	refactored the code that manages the "Slideshow" window into a separate SlideshowWindowController
	changed the Slideshow window to be closable, and fixed window size constraints
	removed prior Leopard seed workarounds that are no longer needed
	updated the included “Cells.qtz” Quartz Composition
	added LSMinimumSystemVersion=10.5 to Info.plist

1.3 - fixed SlideshowView's -transitionToImage: method to message through view's animator to invoke transitions
	added proper QC layer removal in AssetCollectionView's -setUsesQuartzCompositionBackground: method
	reimplemented NSImage category additions using the new NSBitmapImageRep -initWithCGImage: API

1.2 - replaced NSBezierPath rounded-rect category additions with use of the new NSBezierPath API
	“LK” API references renamed to “CA”

1.1 - minor project file update for post-WWDC Leopard seed release (no source code changes relative to 1.0)

1.0 - demonstrated at WWDC 2006 Session 132


================================================================================
Copyright (C) 2006-2013 Apple Inc. All rights reserved.
