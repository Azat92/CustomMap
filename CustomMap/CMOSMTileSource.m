//
//  CMTileRequest.m
//  CustomMap
//
//  Created by Azat Almeev on 07.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMOSMTileSource.h"

@interface CMOSMTileSource ()
{
    dispatch_semaphore_t requestsSemaphore;
    dispatch_semaphore_t cacheSemaphore;
}
@property (nonatomic, retain, readonly) NSMutableArray *requests;
@property (nonatomic, retain, readonly) NSMutableDictionary *cache;
@end

@implementation CMOSMTileSource
@synthesize requests = _requests;
@synthesize cache = _cache;

#pragma mark - Methods
- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    requestsSemaphore = dispatch_semaphore_create(1);
    cacheSemaphore = dispatch_semaphore_create(1);
    return self;
}

#pragma mark - Properties
- (NSMutableArray *)requests
{
    if (!_requests)
        _requests = [NSMutableArray array];
    return _requests;
}

- (NSMutableDictionary *)cache
{
    if (!_cache)
        _cache = [NSMutableDictionary dictionary];
    if (_cache.allKeys.count > 700)
        [_cache removeAllObjects];
    return _cache;
}

#pragma mark - Map Source Delegate
- (CGSize)tileSize
{
    return CGSizeMake(256, 256);
}

- (int)maxZoom
{
    return 17;
}

- (UIImage *)tileForX:(int)x y:(int)y andZoom:(int)zoom completion:(void (^)(BOOL success))completion
{
    NSString *urlName = [NSString stringWithFormat:@"http://tile.openstreetmap.org/%d/%d/%d.png", zoom, x, y];
    UIImage *cacheImage = [self cachedImageForKey:urlName];
    if (cacheImage)
        return cacheImage;

    if (![self checkExistanceAndArrURLForRequest:urlName])
        [self addTileWithName:urlName forDownloadCompletion:completion];
    return nil;
}

#pragma mark - Internal Methods
- (UIImage *)cachedImageForKey:(NSString *)key
{
    UIImage *cached = nil;
    dispatch_semaphore_wait(cacheSemaphore, DISPATCH_TIME_FOREVER);
    cached = self.cache[key];
    dispatch_semaphore_signal(cacheSemaphore);
    return cached;
}

- (void)addImage:(UIImage *)image forKey:(NSString *)key
{
    if (!image)
        return;
    dispatch_semaphore_wait(cacheSemaphore, DISPATCH_TIME_FOREVER);
    self.cache[key] = image;
    dispatch_semaphore_signal(cacheSemaphore);
}

- (BOOL)checkExistanceAndArrURLForRequest:(NSString *)url
{
    BOOL result = YES;
    dispatch_semaphore_wait(requestsSemaphore, DISPATCH_TIME_FOREVER);
    if (![self.requests containsObject:url])
    {
        [self.requests addObject:url];
        result = NO;
    }
    dispatch_semaphore_signal(requestsSemaphore);
    return result;
}

- (void)removeCompletedRequest:(NSString *)url
{
    dispatch_semaphore_wait(requestsSemaphore, DISPATCH_TIME_FOREVER);
    [self.requests removeObject:url];
    dispatch_semaphore_signal(requestsSemaphore);
}

- (void)addTileWithName:(NSString *)name forDownloadCompletion:(void (^)(BOOL success))completion
{
    NSData *dataImg = [NSData dataWithContentsOfURL:[NSURL URLWithString:name]];
    UIImage *img = [UIImage imageWithData:dataImg];
    [self addImage:img forKey:name];
    [self removeCompletedRequest:name];
    completion(img != nil);
}

@end
