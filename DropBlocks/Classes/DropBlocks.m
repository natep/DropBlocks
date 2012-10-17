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

+ (void)loadMetadata:(NSString*)path withHash:(NSString*)hash completionBlock:(LoadMetadataCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadMetadata:path withHash:hash];
}

+ (void)loadMetadata:(NSString*)path atRev:(NSString *)rev completionBlock:(LoadMetadataCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadMetadata:path atRev:rev];
}

+ (void)loadDelta:(NSString *)cursor completionBlock:(LoadDeltaCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadDelta:cursor];
}

+ (void)loadFile:(NSString *)path intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock {
	DropBlocks* db = [DropBlocks newInstanceWithCallback:completionBlock];
	db.secondaryCallback = progressBlock;
	[db.restClient loadFile:path intoPath:destinationPath];
}

+ (void)loadFile:(NSString *)path atRev:(NSString *)rev intoPath:(NSString *)destinationPath completionBlock:(LoadFileCallback)completionBlock progressBlock:(LoadFileProgressCallback)progressBlock {
	DropBlocks* db = [DropBlocks newInstanceWithCallback:completionBlock];
	db.secondaryCallback = progressBlock;
	[db.restClient loadFile:path atRev:rev intoPath:destinationPath];
}


//- (void)cancelFileLoad:(NSString*)path;


+ (void)loadThumbnail:(NSString *)path ofSize:(NSString *)size intoPath:(NSString *)destinationPath completionBlock:(LoadThumbnailCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadThumbnail:path ofSize:size intoPath:destinationPath];
}


//- (void)cancelThumbnailLoad:(NSString*)path size:(NSString*)size;


+ (void)uploadFile:(NSString *)filename toPath:(NSString *)path withParentRev:(NSString *)parentRev fromPath:(NSString *)sourcePath completionBlock:(UploadFileCallback)completionBlock progressBlock:(UploadFileProgressCallback)progressBlock {
	DropBlocks* db = [DropBlocks newInstanceWithCallback:completionBlock];
	db.secondaryCallback = progressBlock;
	[db.restClient uploadFile:filename toPath:path withParentRev:parentRev fromPath:sourcePath];
}


//- (void)cancelFileUpload:(NSString *)path;
//
///* Avoid using this because it is very easy to overwrite conflicting changes. Provided for backwards
// compatibility reasons only */
//- (void)uploadFile:(NSString*)filename toPath:(NSString*)path fromPath:(NSString *)sourcePath __attribute__((deprecated));


+ (void)uploadFileChunk:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath completionBlock:(UploadFileChunkCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient uploadFileChunk:uploadId offset:offset fromPath:localPath];
}

+ (void)uploadFile:(NSString *)filename toPath:(NSString *)parentFolder withParentRev:(NSString *)parentRev fromUploadId:(NSString *)uploadId completionBlock:(UploadFileCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient uploadFile:filename toPath:parentFolder withParentRev:parentRev fromUploadId:uploadId];
}

+ (void)loadRevisionsForFile:(NSString *)path completionBlock:(LoadRevisionsCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadRevisionsForFile:path];
}

+ (void)loadRevisionsForFile:(NSString *)path limit:(NSInteger)limit completionBlock:(LoadRevisionsCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadRevisionsForFile:path limit:limit];
}

+ (void)restoreFile:(NSString *)path toRev:(NSString *)rev completionBlock:(RestoreFileCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient restoreFile:path toRev:rev];
}

+ (void)createFolder:(NSString*)path completionBlock:(CreateFolderCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient createFolder:path];
}

+ (void)deletePath:(NSString*)path completionBlock:(DeletePathCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient deletePath:path];
}

+ (void)copyFrom:(NSString*)fromPath toPath:(NSString *)toPath completionBlock:(CopyPathCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient copyFrom:fromPath toPath:toPath];
}

+ (void)createCopyRef:(NSString *)path completionBlock:(CreateCopyRefCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient createCopyRef:path];
}

+ (void)copyFromRef:(NSString*)copyRef toPath:(NSString *)toPath completionBlock:(CopyFromRefCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient copyFromRef:copyRef toPath:toPath];
}

+ (void)moveFrom:(NSString*)fromPath toPath:(NSString *)toPath completionBlock:(MovePathCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient moveFrom:fromPath toPath:toPath];
}

+ (void)loadAccountInfo:(LoadAccountInfoCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadAccountInfo];
}

+ (void)searchPath:(NSString*)path forKeyword:(NSString*)keyword completionBlock:(SearchPathCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient searchPath:path forKeyword:keyword];
}

+ (void)loadSharableLinkForFile:(NSString *)path shortUrl:(BOOL)createShortUrl completionBlock:(LoadSharableLinkCallback)completionBlock {
	[[DropBlocks newInstanceWithCallback:completionBlock].restClient loadSharableLinkForFile:path shortUrl:createShortUrl];
}

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

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath metadata:(DBMetadata*)metadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadThumbnailCallback handler = strongSelf.callback;
	handler(metadata, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadThumbnailCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
		  metadata:(DBMetadata*)metadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileCallback handler = strongSelf.callback;
	handler(metadata, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress
		   forFile:(NSString*)destPath from:(NSString*)srcPath {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileProgressCallback handler = strongSelf.secondaryCallback;
	
	if (handler) {
		handler(progress);
	}
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient *)client uploadedFileChunk:(NSString *)uploadId newOffset:(unsigned long long)offset
		  fromFile:(NSString *)localPath expires:(NSDate *)expiresDate {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileChunkCallback handler = strongSelf.callback;
	handler(offset, expiresDate, nil);
	[strongSelf cleanup];
}
 
- (void)restClient:(DBRestClient *)client uploadFileChunkFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileChunkCallback handler = strongSelf.callback;
	handler(0, nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath fromUploadId:(NSString *)uploadId
		  metadata:(DBMetadata *)metadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileCallback handler = strongSelf.callback;
	handler(metadata, nil);
	[strongSelf cleanup];
}
 
- (void)restClient:(DBRestClient *)client uploadFromUploadIdFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	UploadFileCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadedRevisions:(NSArray *)revisions forFile:(NSString *)path {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadRevisionsCallback handler = strongSelf.callback;
	handler(revisions, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadRevisionsFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadRevisionsCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client restoredFile:(DBMetadata *)fileMetadata {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	RestoreFileCallback handler = strongSelf.callback;
	handler(fileMetadata, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client restoreFileFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	RestoreFileCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client createdFolder:(DBMetadata*)folder {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CreateFolderCallback handler = strongSelf.callback;
	handler(folder, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client createFolderFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CreateFolderCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client deletedPath:(NSString *)path {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	DeletePathCallback handler = strongSelf.callback;
	handler(nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client deletePathFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	DeletePathCallback handler = strongSelf.callback;
	handler(error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client copiedPath:(NSString *)fromPath to:(DBMetadata *)to {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CopyPathCallback handler = strongSelf.callback;
	handler(to, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client copyPathFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CopyPathCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client createdCopyRef:(NSString *)copyRef {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CreateCopyRefCallback handler = strongSelf.callback;
	handler(copyRef, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client createCopyRefFailedWithError:(NSError *)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CreateCopyRefCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client copiedRef:(NSString *)copyRef to:(DBMetadata *)to {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CopyFromRefCallback handler = strongSelf.callback;
	handler(to, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client copyFromRefFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	CopyFromRefCallback handler = strongSelf.callback;
	handler(nil, error);

}

- (void)restClient:(DBRestClient*)client movedPath:(NSString *)from_path to:(DBMetadata *)result {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	MovePathCallback handler = strongSelf.callback;
	handler(result, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client movePathFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	MovePathCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadedAccountInfo:(DBAccountInfo*)info {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadAccountInfoCallback handler = strongSelf.callback;
	handler(info, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)client loadAccountInfoFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadAccountInfoCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient loadedSearchResults:(NSArray*)results forPath:(NSString*)path keyword:(NSString*)keyword {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	SearchPathCallback handler = strongSelf.callback;
	handler(results, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient searchFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	SearchPathCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient loadedSharableLink:(NSString*)link forFile:(NSString*)path {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadSharableLinkCallback handler = strongSelf.callback;
	handler(link, nil);
	[strongSelf cleanup];
}

- (void)restClient:(DBRestClient*)restClient loadSharableLinkFailedWithError:(NSError*)error {
	//we can run into dealloc problems unless we keep a strong reference to ourselves till the method is done
	DropBlocks* strongSelf = self;
	LoadSharableLinkCallback handler = strongSelf.callback;
	handler(nil, error);
	[strongSelf cleanup];
}

@end
