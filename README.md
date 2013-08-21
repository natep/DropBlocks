DropBlocks
==========

Overview
--------

DropBlocks is a wrapper for the Dropbox iOS SDK that lets you use blocks instead of delegate callbacks.

Usage
-----

Instead of making a call like this:

	[restClient loadFile:path intoPath:destinationPath];

and then implementing these callbacks:

	- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata {
		NSLog(@"Yay, my file loaded. Let me go find that progress view so I can dismiss it ...");
	}

	- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
		NSLog(@"Got some file load progress, let me go find that progress view so I can update it ...");
	}

	- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
		NSLog(@"Uh oh, something went wrong with the file load. Let me go figure out which one that was ...");
	}

With DropBlocks you do it all in one place, like so:

	UIProgressView* progressView = ... //make me a progressView and present it

	[DropBlocks loadFile:path intoPath:intoPath:destinationPath completionBlock:^(NSString* contentType, DBMetadata* metadata, NSError* error) {
		[progressView removeFromSuperview];
		
		if (error) {
			NSLog(@"Uh oh, something went wrong with this file load. I'd better do something about that.");
		} else {
			NSLog(@"Yay, my file loaded. My work here is done.");
		}
	} progressBlock:^(CGFloat progress) {
		progressView.progress = progress;
	}];

Installation
------------

I highly recommend that you use CocoaPods to integrate DropBlocks into your app. If you aren't familiar with it,
CocoaPods is an awesomely simple dependency manager for Objective-C projects. You can get more info about it [here](http://cocoapods.org).

If you're using CocoaPods, all you have to do is put this line in your Podfile:

	pod 'DropBlocks',	'0.0.3'

And you're done. That will also cause the standard Dropbox SDK to be pulled into your project automatically.

***

If you aren't using CocoaPods (Why not? What's your problem??) then you'll have to just grab the DropBlocks
source and drop it into your project. You'll need *DropBlocks.m* and *DropBlocks.h*. You'll also have to manually
integrate the standard Dropbox SDK into your project. Consult the
[Dropbox SDK documentation](https://www.dropbox.com/developers/start/setup#ios) for more information about that.

Setup
-----

You'll need to do all the normal setup for Dropbox in your code (linking account, creating session, etc).
You can find information on that in [Dropbox SDK documentation](https://www.dropbox.com/developers/start/authentication#ios).

DropBlocks is meant to be a replacement for all the calls you would normally make to the DBRestClient class.

Caveats
-------

DropBlocks version 0.0.3 is still a beta release, though it is starting to see use in more productions apps.
Some of the methods have not been thoroughly tested.
Use at your own risk, and please file a bug if you encounter any problems.

Additional Contributors
-------

John Blanco ([ZaBlanc](https://github.com/ZaBlanc)) - Fixed file uploading and improved the callback typedefs for better auto-completion. ([#1](https://github.com/natep/DropBlocks/issues/1)).

Ryan Tsao ([rtsao](https://github.com/rtsao))
	- Fixed progress typedef. ([#3](https://github.com/natep/DropBlocks/issues/3))
	- Added progress block to uploadFileChunk. ([#6](https://github.com/natep/DropBlocks/issues/6))

Contact
-------

If you end up using DropBlocks in a project, I'd love to hear about it.

email: [nate@digitalrickshaw.com](mailto:nate@digitalrickshaw.com)  
twitter: [@nate_petersen](https://twitter.com/nate_petersen)
