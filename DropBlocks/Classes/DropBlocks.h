//
//  DropBlocks.h
//
//  Created by Nate Petersen on 10/8/12.
//  Copyright (c) 2012 Nate Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import <DropboxSDK/DBDeltaEntry.h>

typedef void (^LoadMetadataCallback)(DBMetadata*, NSError*);
typedef void (^LoadDeltaCallback)(NSArray*, BOOL, NSString*, BOOL, NSError*);
typedef void (^LoadStreamableURLCallback)(NSURL*, NSError*);
typedef void (^LoadFileCallback)(NSString*, DBMetadata*, NSError*);
typedef void (^LoadFileProgressCallback)(CGFloat);


@interface DropBlocks : NSObject

+ (void)cancelAllRequests;

+ (void)loadMetadata:(NSString*)path completionBlock:(LoadMetadataCallback)completionBlock;

+ (void)loadDelta:(NSString *)cursor completionBlock:(LoadDeltaCallback)completionBlock;

+ (void)loadFile:(NSString *)path intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock;

+ (void)loadStreamableURLForFile:(NSString *)path completionBlock:(LoadStreamableURLCallback)completionBlock;

@end
