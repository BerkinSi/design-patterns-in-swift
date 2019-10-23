# design-patterns-in-swift

All credits and thanks to raywenderlich.com and Lorenzo Boaro for the tutorial:

https://www.raywenderlich.com/477-design-patterns-on-ios-using-swift-part-1

https://www.raywenderlich.com/476-design-patterns-on-ios-using-swift-part-2-2

**Singleton Pattern (Creational)**

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

The ViewController class has to set itself (or any other object but thats a different story) as dataSource and delegate of HorizontalScrollerView since it is using it. And to be able to set it as delegate and datasource, it has to conform those protocols by implementing required methods.

**Observer Pattern (Behavioural)**

In the Observer pattern, one object notifies other objects of any state changes. The objects involved don't need to know about one another - thus encouraging a decoupled design. This pattern's most often used to notify interested objects when a property has changed.

To provide standalone classes(ie. decoupling) that can be reused, tested and are independent, we need to find a way to make Model objects and View objects communicate without direct references between them. And that's where the Observer pattern comes in.

Cocoa implements the observer pattern in two ways: **Notifications** and **Key-Value Observing (KVO)**.

**Observer Pattern using Notifications**

Below, an example can be found that uses **NotificationCenter** that establishes communication and data transfer between LibraryAPI and AlbumView classes.

First, notification classes name property is extended with static constant BLDownloadImage, adding a new Notification Name.
**static let BLDownloadImage = Notification.Name("BLDownloadImageNotification")**

Then in initializer of AlbumView class, a notification with BLDownloadImage name is posted to NotificationCenter, along with userInfo *containing coverImageView and coverUrl.*

**NotificationCenter.default.post(name: .BLDownloadImage, object: self, userInfo: ["imageView": coverImageView, "coverUrl" : coverUrl])**

Meanwhile, (on the other side of the notification :) in LibraryAPI (remember facade) an observer is added with a selector function which will be triggered when a notification with .BLDownloadImage name is posted.

**NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .BLDownloadImage, object: nil)**

downloadImage(with notification: Notification) function of consumes notification by getting triggered with observer, and using its userInfo property.

**Observer pattern using KVO**

Key-value observing provides a mechanism that allows objects to be notified of changes to specific properties of other objects. It is particularly useful for communication between model and controller layers in an application

https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/KeyValueObserving/KeyValueObserving.html

variable of type NSKeyValueObservation is added to the class AlbumView.

**private var valueObservation: NSKeyValueObservation!**

image view is added as an observer for the image property of the cover image. \.image is the key path expression that enables this mechanism.

**valueObservation = coverImageView.observe(\.image, options: [.new]) { [unowned self] observed, change in
  if change.newValue is UIImage {
      self.indicatorView.stopAnimating()
  }
}**

Key path expression form is **: \<type>.<property>.<subproperty>**

The type can often be inferred by the compiler, but at least 1 property needs to be provided. In some cases, it might make sense to use properties of properties. In your case, the property name, image has been specified, while the type name UIImageView has been omitted.

**Note:** Always remember to remove your observers when they're deinited, or else your app will crash when the subject tries to send messages to these non-existent observers! In this case the valueObservation will be deinited when the album view is, so the observing will stop then.



**Out of Context Caching**

A private variable called cache is initiated in *PersistencyManager* which will return URL for caches directory.

**private var cache: URL {**

**return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]**

**}**

This url is being appended with file name to be used both for writing and reading, in save and load functions.


**let url = cache.appendingPathComponent(filename)**

Filename is retrieved by using coverUrl, which was passed to LibraryAPI with userInfo object of notification, from AlbumView class.

To ensure not to download image if it is cached before, LibraryAPI first tries Persistency Managers getImage method, which checks caches directory.

**guard let data = try? Data(contentsOf: url) else {**

**return nil**

**}**

**return UIImage(data: data)**

If the image is not there, LibraryApi asks for httpclient to download the image and if download is succesful, LibraryAPI saves the image to cache, again using PersistencyManager's save method.

**guard let data = UIImagePNGRepresentation(image) else {**

**return**

**}**

**try? data.write(to: url)**
