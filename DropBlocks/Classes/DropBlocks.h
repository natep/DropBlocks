//
//  DropBlocks.h
//
//  Created by Nate Petersen on 10/8/12.
//  Copyright (c) 2012 Nate Petersen. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef COCOAPODS
	#import "DropboxSDK.h"
	#import "DBDeltaEntry.h"
#else
	#import <DropboxSDK/DropboxSDK.h>
	#import <DropboxSDK/DBDeltaEntry.h>
#endif

typedef void (^LoadMetadataCallback)(DBMetadata *metadata, NSError *error);
typedef void (^LoadDeltaCallback)(NSArray *entries, BOOL shouldReset, NSString *cursor, BOOL hasMore, NSError *error);
typedef void (^LoadStreamableURLCallback)(NSURL *url, NSError *error);
typedef void (^LoadFileCallback)(NSString *contentType, DBMetadata *metadata, NSError *error);
typedef void (^LoadFileProgressCallback)(CGFloat progress);
typedef void (^LoadThumbnailCallback)(DBMetadata *metadata, NSError *error);
typedef void (^UploadFileCallback)(NSString *destDir, DBMetadata *metadata, NSError *error);
typedef void (^UploadFileProgressCallback)(CGFloat progress);
typedef void (^UploadFileChunkCallback)(NSString *uploadId, unsigned long long offset, NSDate *expiresDate, NSError *error);
typedef void (^UploadFileChunkProgressCallback)(CGFloat progress);
typedef void (^LoadRevisionsCallback)(NSArray *revisions, NSError *error);
typedef void (^RestoreFileCallback)(DBMetadata *metadata, NSError *error);
typedef void (^CreateFolderCallback)(DBMetadata *metadata, NSError *error);
typedef void (^DeletePathCallback)(NSError *error);
typedef void (^CopyPathCallback)(DBMetadata *metadata, NSError *error);
typedef void (^CreateCopyRefCallback)(NSString *copyRef, NSError *error);
typedef void (^CopyFromRefCallback)(DBMetadata *metadata, NSError *error);
typedef void (^MovePathCallback)(DBMetadata *metadata, NSError *error);
typedef void (^LoadAccountInfoCallback)(DBAccountInfo *metadata, NSError *error);
typedef void (^SearchPathCallback)(NSArray *results, NSError *error);
typedef void (^LoadSharableLinkCallback)(NSString *link, NSError *error);


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

+ (void)uploadFileChunk:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath completionBlock:(UploadFileChunkCallback)completionBlock progressBlock:(UploadFileChunkProgressCallback)progressBlock;

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
