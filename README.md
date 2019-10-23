# design-patterns-in-swift

All credits and thanks to raywenderlich.com and Lorenzo Boaro for the tutorial:
https://www.raywenderlich.com/477-design-patterns-on-ios-using-swift-part-1
https://www.raywenderlich.com/476-design-patterns-on-ios-using-swift-part-2-2

**Sinlgeton Pattern (Creational)**

Library API class is implemented to be used as a Singleton Object.
**Static constant** variable shared is added to class to make object accessible from outside,
and **init** is marked as **private** to ensure there is only one instance of the class.


**Facade Pattern (Structural)**
The Facade design pattern provides a single interface to a complex subsystem. Instead of exposing the user to a set of classes and their APIs, you only expose one simple unified API.

**private let persistencyManager = PersistencyManager()**
**private let httpClient = HTTPClient()**
LibraryAPI holds instances of PersistencyManager and HTTPClient and exposes a simple API to access those services.

In other words, Library API class is used across the project while it uses PersistencyManager and HTTPClient.
Reminder: There is no mechanism for developers to use PersistencyManager or HTTPClient classes. 

**Decorator Pattern (Structural)**
The Decorator pattern dynamically adds behaviors and responsibilities to an object without modifying its code. It’s an alternative to subclassing where you modify a class’s behavior by wrapping it with another object.

Decorator pattern is being used in **Album Class**, with **Extension** mechanism of Swift. 
Album class is extended with a variable called tableRepresentation to expose a representable data to view class.

Important Reminder: Overriding is not allowed within extensions.

Decorator pattern is used with swift's **Delegation Mechanism** in ViewController.
Delegation, is a mechanism in which one object acts on behalf of, or in coordination with, another object
ViewController conforms to protocols of UITableview class to be able to serve it as both datasource and delegate. By doing so, ViewController class is decorated to work in coordination with UITableView class.

**Adapter Pattern (Structural)**
Apple is using Adapter pattern with protocols like UITableViewDelegate, UIScrollViewDelegate, NSCoding and NSCopying. As an example, with the NSCopying protocol, any class can provide a standard copy method.

It basically is using protocols to make incompatible interfaces work together.
HorizontalScrollerView class is created with variables 
  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?
both referring to protocols above the class. These variables have to be set in order to use the HorizontalScrollerView.

The ViewController class has to set itself (or any other object bot thats a different story) as dataSource and delegate of HorizontalScrollerView since it is using it. And to be able to set it as delegate and datasource, it has to conform those protocols by implementing required methods.

