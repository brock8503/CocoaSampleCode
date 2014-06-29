
TwoManyControllers
==================

Abstract
-------- 
This sample demonstrates how NSArrayControllers can be used to produce a user interface that traverses multiple (in this case two) to-many relationships.  The basic model consists of a Product with a to-many relationship to a Version which in turn has a to-many relationship to a License.  That is, a product has many versions, and a version has many licenses. 

In this example, we would like the user to be able to select a single Product and display all the Licenses associated with that Product.  To accomplish this we use an intermediate NSArrayController that holds an array of all the Versions associated with the selected Product.  We then populate the Licenses NSArrayController with the distinct set of objects returned from asking every Version object in the Versions Array Controller (the arrangedObjects) for its Licenses key path. 


Usage
-----
Use the top half of the interface to add projects, versions, and licenses.  You need to add some sample data to appreciate the purpose of this sample.

Use the bottom portion of the UI select a product and view all of its licenses.  This is accomplished entirely using NSArrayControllers and bindings.


Model Details
-------------
Please refer to APLDocument.xcdatamodel within the project.


Bindings Details
----------------
Please refer to BindingsDiagram.pdf for a high level view of the bindings used in this sample.  The diagram should act as a good starting point in determining which bindings to inspect in Interface Builder.  The diagram aims to be less of an exhaustive reference for the details about each binding and more of a high-level guide to how the controllers and the UI in the sample interact.