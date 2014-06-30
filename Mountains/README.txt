
Mountains
=========

Mountains demonstrates how to internationalize and localize an application.

Some of the techniques illustrated are:

* The Base Localization feature introduced in Xcode 4.5.
* Using localized strings and other data;
* Getting data from an NSLocale;
* Using an NSLocale with other classes such as NSDateFormatter to generate appropriately localized results; and
* Embedding parameter ordering information in the format string used with NSString's stringWithFormat: method.

The interface file, MainMenu.xib, uses Auto layout. Notice also that the text direction in the table view cells (Attributes inspector) is set to Natural.


Mountains has two classes: APLMountain and APLAppDelegate.

The APLMountain class is a simple key-value coded class that holds three pieces of information about a particular mountain: its name, its height (in meters), and the date it was first climbed (if known). These are represented using an NSString, NSNumber, and NSDate object respectively.

The APLAppDelegate class coordinates the user interface.  It has a list of mountains and uses a table view to let the user select one.  It also allows the user to override the locale's calendar.

Five localizations are provided: en (English), fr (French), ru (Russian), ja (Japanese), zh_Hant (traditional Chinese). Each localization contains four files: InfoPlist.strings (the localized messages used by AppKit to display copyright information), MainMenu.strings (strings used to localize the nib), Mountains.strings (localized strings), and Mountains.plist (a locale-specific list of interesting mountains). Whether your application needs locale-specific data depends on the nature of the application itself -- in some domains the data may be independent of the locale. If you store information such as times, though, you should make sure that it can be appropriately interpreted in any locale.

You can preview a localized interface by displaying the xib file in the main Editor pane and dragging the MainMenu strings file for the locale into it.
