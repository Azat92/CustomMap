//
//  CMLocationGetter.m
//  CustomMap
//
//  Created by Azat Almeev on 11.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMLocationGetter.h"

@interface CMLocationGetter () <CLLocationManagerDelegate>
{
    CLLocationCoordinate2D myCoord;
}
@property (nonatomic, retain, readonly) NSMutableArray *completionArray;
@property (nonatomic, retain, readonly) CLLocationManager *locationManager;
@end

@implementation CMLocationGetter
@synthesize completionArray = _completionArray;
@synthesize locationManager = _locationManager;

#pragma mark - Properties
- (NSMutableArray *)completionArray
{
    if (!_completionArray)
        _completionArray = [NSMutableArray new];
    return _completionArray;
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        _locationManager.distanceFilter = 100;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            [_locationManager requestWhenInUseAuthorization];
    }
    return _locationManager;
}

#pragma mark - Methods
+ (instancetype)sharedInstance
{
    static id _singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleton = [[self alloc] init];
    });
    return _singleton;
}

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    [self.locationManager startUpdatingLocation];
    myCoord = kCLLocationCoordinate2DInvalid;
    return self;
}

+ (void)subscribeToUpdateUserLocation:(void(^)(CLLocationCoordinate2D coordinate, NSString *message))completion
{
    [[self sharedInstance] subscribeToUpdateUserLocation:completion];
}

#pragma mark - Internal
- (void)subscribeToUpdateUserLocation:(void(^)(CLLocationCoordinate2D coordinate, NSString *message))completion
{
    if (!completion)
        return;
    
    if (CLLocationCoordinate2DIsValid(myCoord))
        completion(myCoord, nil);
    else
        [self.completionArray addObject:completion];
}

- (void)alertSubscribersWithCoord:(CLLocationCoordinate2D)coord message:(NSString *)message
{
    if (![CLLocationManager locationServicesEnabled])
        message = @"You should enable geolocation services to determine your position";
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        message = @"You should enable app use geolocation services";
    for (void(^block)(CLLocationCoordinate2D, NSString *) in self.completionArray)
        block(coord, message);
}

#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        myCoord = location.coordinate;
        [self alertSubscribersWithCoord:myCoord message:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    MYLog(@"CLLocationManagerDidFailWithError: %@", error.localizedDescription);
    [self alertSubscribersWithCoord:kCLLocationCoordinate2DInvalid message:error.localizedDescription];
}

@end
