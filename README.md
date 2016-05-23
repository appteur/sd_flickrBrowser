#flickrBrowser


### Overview
This is a demo app I put together in a few hours to test my abilities. 

This flickr browser uses an instagram-like feed that loads images from flickr.  
It has built in search for images matching a given query and will also find images around your selected location. (It will use your gps location or allow you to select from a map.)

##### Things you should know
I setup a configuration file in this app where you will need to place your flickr api key before you try to build and run this app. Look for this method and replace the defined string with your own api key.

```objective-c

+(NSString*) key_api
{
    return @"<YOUR API KEY GOES HERE>";
}

```

#### Basic App Structure

As far as design goes, this app uses some MVVM architecture in an effort to combat the 'massive view controller' effect. 

The photo feed view controller only handles logic related to user interaction and displaying the photo data received from the flickr api. The photo data is encapsulated in SDFlickrResultData objects. These objects are received from the ViewModelPhotoFeed class in response to user actions that initiate requests to the api for more data.

When a user interacts with any of the search options, (or launches the app) a request is initiated with the view model, which in turns initiates a network request for data through the SDFlickrClient network class. The data that is received from the flickr api is converted into SDFlickrResultData objects and passed back to the view controller in an array. The view controller updates its tabledata array and updates the display.

I opted to use AFNetworking for this version with an SDApiClient class that handles requests and is a subclass of AFHTTPSessionManager. I created an SDFlickrClient class as sort of an adapter to handle the business logic of generating the requests to the flickr api, then ran those requests through my more generic SDApiClient networking class. This was to separate the actual networking logic from the flickr api specific logic and create a cleaner process.  
I also added an SDFlickrPhotosResponse class so I could reformat the data received from the api as json into the format I wanted the app to consume, as well as to make it easier to access that data from the api using class .syntax instead of the dictionary[@"myKey"] format.

In the networking classes you'll also find a set of classes I had fun writing awhile ago. It's the SDPing collection of classes. These classes make use of Apple's SimplePing class and make it easier to 'ping' your server to validate that you actually have a connection available to your server. It's kind of an extra check on top of the Reachability code. When Reachability says that your network changed, you can quickly and easily validate that you can still reach your server.

In this project you'll also find some custom views, a date formatter class and some categories to make cleaner use of functionality I wanted to add.

There are also some location classes I put together called SDLocation with some geofencing logic and methods I put together for another project I was working on. There is a location manager that handles finding your current location if you want to search for photos using CoreLocation, and fires location status update notifications that can be used to update your 'Resolving Location' alert displayed to the user.

Here's a list of things I'd like to do to improve this project:
- Move requests into an operation queue so they'll be cancellable.
- Add ability for users to log into their flickr accounts to post photos.
- Add comment and like functionality.
- Write a Swift version.


#### Notes
This app is a rough first draft. I may come back and refine it at some point. I've considered polishing it up a bit, adding some more features and releasing it to the app store, but we'll see. I have a number of other projects to build as well. If you'd like to see more development on this project reach out to me and let me know.




#### Build Info

This app was built using Xcode 7.3.

To run this app you will need to replace the bundle identifier with one that you control and that will work using your own provisioning profiles and certificates.