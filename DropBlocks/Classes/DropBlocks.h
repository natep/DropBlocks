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
typedef void (^LoadThumbnailCallback)(DBMetadata*, NSError*);
typedef void (^UploadFileCallback)(DBMetadata*, NSError*);
typedef void (^UploadFileProgressCallback)(CGFloat);
typedef void (^UploadFileChunkCallback)(unsigned long long, NSDate*, NSError*);
typedef void (^LoadRevisionsCallback)(NSArray*, NSError*);
typedef void (^RestoreFileCallback)(DBMetadata*, NSError*);
typedef void (^CreateFolderCallback)(DBMetadata*, NSError*);
typedef void (^DeletePathCallback)(NSError*);
typedef void (^CopyPathCallback)(DBMetadata*, NSError*);
typedef void (^CreateCopyRefCallback)(NSString*, NSError*);
typedef void (^CopyFromRefCallback)(DBMetadata*, NSError*);
typedef void (^MovePathCallback)(DBMetadata*, NSError*);
typedef void (^LoadAccountInfoCallback)(DBAccountInfo*, NSError*);
typedef void (^SearchPathCallback)(NSArray*, NSError*);
typedef void (^LoadSharableLinkCallback)(NSString*, NSError*);


@interface DropBlocks : NSObject

+ (void)cancelAllRequests;

+ (void)loadMetadata:(NSString*)path completionBlock:(LoadMetadataCallback)completionBlock;
+ (void)loadMetadata:(NSString*)path withHash:(NSString*)hash completionBlock:(LoadMetadataCallback)completionBlock;
+ (void)loadMetadata:(NSString*)path atRev:(NSString *)rev completionBlock:(LoadMetadataCallback)completionBlock;

+ (void)loadDelta:(NSString *)cursor completionBlock:(LoadDeltaCallback)completionBlock;

+ (void)loadFile:(NSString *)path intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock;
+ (void)loadFile:(NSString *)path atRev:(NSString *)rev intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock;

+ (void)loadThumbnail:(NSString *)path ofSize:(NSString *)size intoPath:(NSString *)destinationPath completionBlock:(LoadThumbnailCallback)completionBlock;

+ (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev fromPath:(NSString *)sourcePath completionBlock:(UploadFileCallback)completionBlock progressBlock:(UploadFileProgressCallback)progressBlock;

+ (void)uploadFileChunk:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath completionBlock:(UploadFileChunkCallback)completionBlock;

+ (void)uploadFile:(NSString *)filename toPath:(NSString *)parentFolder withParentRev:(NSString *)parentRev fromUploadId:(NSString *)uploadId completionBlock:(UploadFileCallback)completionBlock;

+ (void)loadRevisionsForFile:(NSString *)path completionBlock:(LoadRevisionsCallback)completionBlock;

+ (void)loadRevisionsForFile:(NSString *)path limit:(NSInteger)limit completionBlock:(LoadRevisionsCallback)completionBlock;

+ (void)restoreFile:(NSString *)path toRev:(NSString *)rev completionBlock:(RestoreFileCallback)completionBlock;

+ (void)createFolder:(NSString*)path completionBlock:(CreateFolderCallback)completionBlock;

+ (void)deletePath:(NSString*)path completionBlock:(DeletePathCallback)completionBlock;

+ (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath completionBlock:(CopyPathCallback)completionBlock;

+ (void)createCopyRef:(NSString *)path completionBlock:(CreateCopyRefCallback)completionBlock;

+ (void)copyFromRef:(NSString*)copyRef toPath:(NSString *)toPath completionBlock:(CopyFromRefCallback)completionBlock;

+ (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath completionBlock:(MovePathCallback)completionBlock;

+ (void)loadAccountInfo:(LoadAccountInfoCallback)completionBlock;

+ (void)searchPath:(NSString*)path forKeyword:(NSString*)keyword completionBlock:(SearchPathCallback)completionBlock;

+ (void)loadSharableLinkForFile:(NSString *)path shortUrl:(BOOL)createShortUrl completionBlock:(LoadSharableLinkCallback)completionBlock;

+ (void)loadStreamableURLForFile:(NSString *)path completionBlock:(LoadStreamableURLCallback)completionBlock;



@end
