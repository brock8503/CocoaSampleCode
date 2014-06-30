AddressBookCocoa
This sample demonstrates how to create, access, add, search, and retrieve records using Address Book's Objective-C APIs. It defines and implements the addContact and findContact methods to perform these tasks. The addContact method creates a person named Elba, sets its first and last name, address, and phone number information, and adds him to the Address Book. The findContact method looks for Elba in Address Book using ABPerson’s searchElementForProperty:label:key:value:comparison: API and fetches his first name, street address, and work fax number.


Build requirements
OS X SDK 10.8 or later


Runtime requirements
OS X 10.7 or later


Using the Sample
The application shows the first and last name, address, and phone number of a contact named Elba. 
Click on the "Add this person to ..." button to add Elba to your Address Book. 
Click on the "Find this info for... " button to retrieve Elba's first name, street address, and work fax number.


Change from Previous Versions
1.0 -First Release
1.1 -Updaded to support Xcode 3.0 or later. Set Base SDK and Deployment Target to Mac OS X 10.5 and Mac OS X 10.4, respectively.
1.2 -Updated for OS X 10.8, now supports sandboxing.


Copyright (C) 2002-2013 Apple Inc. All rights reserved.