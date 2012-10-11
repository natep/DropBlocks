//
//  DropBlocks.m
//
//  Created by Nate Petersen on 10/8/12.
//  Copyright (c) 2012 Nate Petersen. All rights reserved.
//

#import "DropBlocks.h"

static NSMutableSet* activeWrappers = nil;

@interface DropBlocks () <DBRestClientDelegate>

@property(nonatomic, strong) DBRestClient* restClient;
@property(nonatomic, copy) id callback;
@property(nonatomic, copy) id secondaryCallback;

@end

@implementation DropBlocks

+ (void)initialize {
	activeWrappers = [[NSMutableSet alloc] init];
}

- (id)init {
	if ((self = [super init])) {
		self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		self.restClient.delegate = self;
	}
	
	return self;
}

+ (DropBlocks*)newInstanceWithCallback:(id)callback {
	DropBlocks* db = [[DropBlocks alloc] init];
	db.callback = callback;
	[activeWrappers addObject:db];
	
	return db;
}

+ (void)cancelAllRequests {
	for (DropBlocks* db in activeWrappers) {
		[db.restClient cancelAllRequests];
	}
	
	[activeWrappers removeAllObjects];
}

/*
 * Loads metadata for the object at the given root/path. Results are handled by the provided
 * completion block.
 *  - If the error is non-nil, the Dropbox SDK reported an error.
 *  - If there is no error but the metadata object is nil, that means that the metadata was unchanged.
 *  - Otherwise a metadata object should be returned.
 */
+ (void)loadMetadata:(NSString*)path completionBlock:(LoadMetadataCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadMetadata:path];
}

///* Loads metadata for the object at the given root/path and returns the result to the delegate as a
// dictionary */
//- (void)loadMetadata:(NSString*)path withHash:(NSString*)hash;
//
///* This will load the metadata of a file at a given rev */
//- (void)loadMetadata:(NSString *)path atRev:(NSString *)rev;
//


+ (void)loadDelta:(NSString *)cursor completionBlock:(LoadDeltaCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadDelta:cursor];
}


+ (void)loadFile:(NSString *)path intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock {
	DropBlocks* db = [DropBlocks newInstanceWithCallback:completionBlock];
	db.secondaryCallback = progressBlock;
	[db.restClient loadFile:path intoPath:destinationPath];
}


///* This will load a file as it existed at a given rev */
//- (void)loadFile:(NSString *)path atRev:(NSString *)rev intoPath:(NSString *)destPath;
//
//- (void)cancelFileLoad:(NSString*)path;
//
//
//- (void)loadThumbnail:(NSString *)path ofSize:(NSString *)size intoPath:(NSString *)destinationPath;
//- (void)cancelThumbnailLoad:(NSString*)path size:(NSString*)size;
//
///* Uploads a file that will be named filename to the given path on the server. sourcePath is the
// full path of the file you want to upload. If you are modifying a file, parentRev represents the
// rev of the file before you modified it as returned from the server. If you are uploading a new
// file set parentRev to nil. */
//- (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev
//		  fromPath:(NSString *)sourcePath;
//
//- (void)cancelFileUpload:(NSString *)path;
//
///* Avoid using this because it is very easy to overwrite conflicting changes. Provided for backwards
// compatibility reasons only */
//- (void)uploadFile:(NSString*)filename toPath:(NSString*)path fromPath:(NSString *)sourcePath __attribute__((deprecated));
//
///* These calls allow you to upload files in chunks, which is better for file larger than a few megabytes.
// You can append bytes to the file using -[DBRestClient uploadFileChunk:offset:uploadId:] and then call
// -[DBRestClient uploadFile:toPath:withParentRev:fromUploadId:] to turn the bytes appended at that uploadId
// into an actual file in the user's Dropbox.
// Use a nil uploadId to start uploading a new file. */
//- (void)uploadFileChunk:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath;
//- (void)uploadFile:(NSString *)filename toPath:(NSString *)parentFolder withParentRev:(NSString *)parentRev
//	  fromUploadId:(NSString *)uploadId;
//
//
///* Loads a list of up to 10 DBMetadata objects representing past revisions of the file at path */
//- (void)loadRevisionsForFile:(NSString *)path;
//
///* Same as above but with a configurable limit to number of DBMetadata objects returned, up to 1000 */
//- (void)loadRevisionsForFile:(NSString *)path limit:(NSInteger)limit;
//
///* Restores a file at path as it existed at the given rev and returns the metadata of the restored
// file after restoration */
//- (void)restoreFile:(NSString *)path toRev:(NSString *)rev;
//
///* Creates a folder at the given root/path */
//- (void)createFolder:(NSString*)path;
//
//- (void)deletePath:(NSString*)path;
//
//- (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath;
//
//- (void)createCopyRef:(NSString *)path; // Used to copy between Dropboxes
//- (void)copyFromRef:(NSString*)copyRef toPath:(NSString *)toPath; // Takes copy ref created by above call
//
//- (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath;
//
//- (void)loadAccountInfo;
//
//- (void)searchPath:(NSString*)path forKeyword:(NSString*)keyword;
//
//- (void)loadSharableLinkForFile:(NSString *)path;
//- (void)loadSharableLinkForFile:(NSString *)path shortUrl:(BOOL)createShortUrl;
//


+ (void)loadStreamableURLForFile:(NSString *)path completionBlock:(LoadStreamableURLCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadStreamableURLForFile:path];
}

- (void)cleanup {
	//this seems to be necessary for some reason, or else DBRestClient blows up because things got dealloced
	dispatch_async(dispatch_get_main_queue(), ^{
		[activeWrappers removeObject:self];
	});
}

#pragma mark - Standard Dropbox callbacks

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadMetadataCallback handler = strongSelf.callback;
	handler(metadata, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadMetadataCallback handler = strongSelf.callback;
	handler(nil, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadMetadataCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadedDeltaEntries:(NSArray *)entries reset:(BOOL)shouldReset cursor:(NSString *)cursor hasMore:(BOOL)hasMore {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadDeltaCallback handler = strongSelf.callback;
	handler(entries, shouldReset, cursor, hasMore, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadDeltaFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadDeltaCallback handler = strongSelf.callback;
	handler(nil, NO, nil, NO, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient loadedStreamableURL:(NSURL*)url forFile:(NSString*)path {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadStreamableURLCallback handler = strongSelf.callback;
	handler(url, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient loadStreamableURLFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadStreamableURLCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath contentType:(NSString*)contentType metadata:(DBMetadata*)metadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadFileCallback handler = strongSelf.callback;
	handler(contentType, metadata, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadFileProgressCallback handler = strongSelf.secondaryCallback;
	
	if (handler) {
		handler(progress);
	}
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadFileCallback handler = strongSelf.callback;
	handler(nil, nil, error);
	[strongSelf cleanup];
}

@end
