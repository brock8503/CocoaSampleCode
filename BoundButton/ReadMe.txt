
BoundButton
===========

This simple application illustrates how you can use Cocoa bindings to bind the target and argument parameters of a button.

--------------------------------

Using the Sample
Build and run the sample using Xcode. Select an entree and one or more toppings, then click the "Place your order" button.

--------------------------------

In many cases, there is no need to use Cocoa bindings with a button -- the target/action pattern is more appropriate.  Sometimes, however, it may be convenient to use bindings to collect information from your application and pass it to the target using the method arguments.

In this example, the user is presented with two simple table views containing entrees and toppings managed by array controllers.  The user selects one entree and any number of toppings and presses a button to submit an order.

The method to submit the order (orderEntree:withToppings:) takes two arguments, the selected entree and toppings.  These are the 'selection' of the entrees array controller and 'selectedObjects' of the toppings array controller, respectively.  The order controller object could retrieve these directly from the array controllers, but this would require it to have outlets to the array controllers and a couple of extra method calls.  Instead, these values can be retrieved using bindings. Note that the entrees table view only allows single selection, but the toppings table view allows multiple selection.


The button's Action Invocation bindings are specified as follows:
 
    * 'target' is bound to [APLOrderController].self' -- this uses 'self' as a key simply to return the APLOrderController instance.
 
The selector (specified in the target binding) is orderEntree:withToppings:. The multi-value binding (parameters) for the target's action method are as follows:
    
    1) argument is [Entrees].selection -- the selection is passed as the first argument to orderEntree:withToppings:.  The selection is a proxy object representing the array controller's selection, but this is OK since it is only accessed using key-value coding methods.
 
    2) argument2 is [Toppings].selectedObjects -- the (entree) objects currently selected in the toppings table view.


When the button is pressed it sends its target (the OrderController instance) an orderEntree:withToppings: message with the arguments as the single selection of the entrees array controller, as well as the (possibly multiple) selectedObjects of the toppings array controller.

--------------------------------

Main files

APLOrderController.{h,m}
    The primary instance of this class controls what data is bound to the table views (entrees and toppings). This also contains the logic for what happens once the "Place your order" button is selected.

MainMenu.xib
	An Interface Builder "nib" file with only the main menu in it. It will be loaded when the application is first launched, and its "File's Owner" is the instance of NSApplication.

--------------------------------

Copyright (C) 2012-13 Apple Inc. All rights reserved.
