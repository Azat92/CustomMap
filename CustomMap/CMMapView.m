//
//  CMMapView.m
//  CustomMap
//
//  Created by Azat Almeev on 10.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMMapView.h"
#import "CMTiledMapView.h"
#import "CMLocalSource.h"
#import "CMOSMTileSource.h"
#import "CMProjection.h"
#import "CMLocationGetter.h"

#define kSuccessKey  @"success"
#define kLocationKey @"location"
#define kErrorKey    @"error"

@interface CMMapView () <UIScrollViewDelegate, CLLocationManagerDelegate>
@property (nonatomic) CLLocationCoordinate2D myCoord;
@property (nonatomic, retain, readonly) UIView *point;
@property (nonatomic) CLLocationCoordinate2D searchCoord;
@property (nonatomic, retain, readonly) UIView *searchPoint;
@property (nonatomic, retain, readonly) CMProjection *projection;
@property (nonatomic, retain, readonly) UIScrollView *mapScrollView;
@property (nonatomic, retain, readonly) CMTiledMapView *tiledView;
@property (nonatomic, retain, readonly) id <CMMapSource> tileSource;
@property (nonatomic, retain, readonly) CLGeocoder *geocoder;
@end

@implementation CMMapView
@synthesize delegate;
@synthesize myCoord = _myCoord;
@synthesize point = _point;
@synthesize searchCoord = _searchCoord;
@synthesize searchPoint = _searchPoint;
@synthesize projection = _projection;
@synthesize mapScrollView = _mapScrollView;
@synthesize tiledView = _tiledView;
@synthesize tileSource = _tileSource;
@synthesize geocoder = _geocoder;

#pragma mark - Properties
- (CLLocationCoordinate2D)myCoord
{
    return _myCoord;
}

- (void)setMyCoord:(CLLocationCoordinate2D)myCoord
{
    _myCoord = myCoord;
    [self updateMyPositionOnScreen];
    [self geocodeLocation:self.myCoord completion:^(NSDictionary *result) {
        if ([result[kSuccessKey] boolValue])
            [self.delegate mapView:self didUpdatedUserLocation:result[kLocationKey]];
        else
            [self.delegate mapView:self didFailUpdateUserLocation:result[kErrorKey]];
    }];
}

- (UIView *)point
{
    if (!_point)
    {
        _point = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 11, 11)];
        _point.backgroundColor = [UIColor redColor];
        _point.layer.cornerRadius = 6;
        _point.hidden = YES;
    }
    return _point;
}

- (CLLocationCoordinate2D)searchCoord
{
    return _searchCoord;
}

- (void)setSearchCoord:(CLLocationCoordinate2D)searchCoord
{
    _searchCoord = searchCoord;
    [self updateSearchLocationOnScreen];
    if (!self.searchPoint.hidden)
        [self.mapScrollView scrollRectToVisible:self.searchPoint.frame animated:YES];
}

- (UIView *)searchPoint
{
    if (!_searchPoint)
    {
        _searchPoint = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 11, 11)];
        _searchPoint.backgroundColor = [UIColor blueColor];
        _searchPoint.layer.cornerRadius = 6;
        _searchPoint.hidden = YES;
    }
    return _searchPoint;
}

- (CMProjection *)projection
{
    if (!_projection)
        _projection = [CMProjection EPSG900913projection];
    return _projection;
}

- (UIScrollView *)mapScrollView
{
    if (!_mapScrollView)
    {
        _mapScrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _mapScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _mapScrollView.bounces = NO;
        _mapScrollView.bouncesZoom = NO;
        _mapScrollView.showsHorizontalScrollIndicator = NO;
        _mapScrollView.showsVerticalScrollIndicator = NO;
        _mapScrollView.delegate = self;
        _mapScrollView.contentSize = self.tileSource.tileSize;
        _mapScrollView.maximumZoomScale = exp2f(self.tileSource.maxZoom);
    }
    return _mapScrollView;
}

- (CMTiledMapView *)tiledView
{
    if (!_tiledView)
    {
        _tiledView = [[CMTiledMapView alloc]initWithFrame:(CGRect){ {0, 0}, self.tileSource.tileSize} tilesSource:self.tileSource];
        _tiledView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _tiledView;
}

- (id <CMMapSource>)tileSource
{
    if (!_tileSource)
        _tileSource = [[CMOSMTileSource alloc]init];
//        _tileSource = [[CMLocalSource alloc]init];
    return _tileSource;
}

- (CLGeocoder *)geocoder
{
    if (!_geocoder)
        _geocoder = [[CLGeocoder alloc] init];
    return _geocoder;
}

#pragma mark - Methods
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self addSubview:self.mapScrollView];
        [self.mapScrollView addSubview:self.tiledView];
        self.myCoord = kCLLocationCoordinate2DInvalid;
        self.searchCoord = kCLLocationCoordinate2DInvalid;
        [self.mapScrollView addSubview:self.point];
        [self.mapScrollView addSubview:self.searchPoint];
        __weak typeof(self) self_ = self;
        [CMLocationGetter subscribeToUpdateUserLocation:^(CLLocationCoordinate2D coord, NSString *message) {
            self_.myCoord = coord;
            if (message)
                [self.delegate mapView:self_ didFailUpdateUserLocation:message];
        }];
    }
    return self;
    
}

- (void)moveToStartPosition
{
    [self.mapScrollView setZoomScale:exp2(3) animated:YES];
    [self.mapScrollView setContentOffset:CGPointMake(800, 300) animated:YES];
}

- (void)searchByQuery:(NSString *)query
{
    if (!query || [query isEqualToString:@""])
        return;
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = query;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
         MKPlacemark *first = [[response.mapItems firstObject] placemark];
         if (first)
             self.searchCoord = first.coordinate;
     }];
}

#pragma mark - Internal
- (CGPoint)coordinateToPixel:(CLLocationCoordinate2D)coordinate
{
    return [self projectedPointToPixel:[self.projection coordinateToProjectedPoint:coordinate]];
}

- (CGPoint)projectedPointToPixel:(CMProjectedPoint)projectedPoint
{
    CMProjectedRect planetBounds = self.projection.planetBounds;
    CMProjectedPoint normalizedProjectedPoint;
	normalizedProjectedPoint.x = projectedPoint.x + fabs(planetBounds.origin.x);
	normalizedProjectedPoint.y = projectedPoint.y + fabs(planetBounds.origin.y);
    double metersPerPixel = planetBounds.size.width / self.mapScrollView.contentSize.width;
    CGPoint projectedPixel = { (normalizedProjectedPoint.x / metersPerPixel),
        (self.mapScrollView.contentSize.height - (normalizedProjectedPoint.y / metersPerPixel)) };
    return projectedPixel;
}

- (void)updateMyPositionOnScreen
{
    if (CLLocationCoordinate2DIsValid(self.myCoord))
    {
        CGPoint myPoint = [self coordinateToPixel:self.myCoord];
        CGRect pFrame = self.point.frame;
        pFrame.origin = myPoint;
        self.point.frame = pFrame;
        self.point.hidden = NO;
    }
    else
        self.point.hidden = YES;
}

- (void)updateSearchLocationOnScreen
{
    if (CLLocationCoordinate2DIsValid(self.searchCoord))
    {
        CGPoint srchPoint = [self coordinateToPixel:self.searchCoord];
        CGRect pFrame = self.searchPoint.frame;
        pFrame.origin = srchPoint;
        self.searchPoint.frame = pFrame;
        self.searchPoint.hidden = NO;
    }
    else
        self.searchPoint.hidden = YES;
}

#pragma mark - Scroll View Delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.tiledView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateMyPositionOnScreen];
    [self updateSearchLocationOnScreen];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self updateMyPositionOnScreen];
    [self updateSearchLocationOnScreen];
}

#pragma mark - Geocoding
- (void)geocodeLocation:(CLLocationCoordinate2D)location completion:(void (^)(NSDictionary *result))completion
{
    if (!CLLocationCoordinate2DIsValid(location))
        return;
    [self.geocoder reverseGeocodeLocation:[[CLLocation alloc]initWithLatitude:location.latitude longitude:location.longitude] completionHandler:^(NSArray* placemarks, NSError* error) {
        CLPlacemark *placemark = [placemarks firstObject];
        if (error)
        {
            MYLog(@"ReverseGeocodingDidFailWithError: %@", error.localizedDescription);
            completion(@{ kSuccessKey: @NO, kErrorKey : error.localizedDescription });
        }
        else
            completion(@{ kSuccessKey: @YES, kLocationKey : placemark.description });
    }];
}

@end
