//
//  CMProjection.m
//  CustomMap
//
//  Created by Azat Almeev on 09.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMProjection.h"
#import "proj_api.h"

@interface CMProjection ()
{
    void *internalProjection;
}
@end

@implementation CMProjection
@synthesize planetBounds = _planetBounds;

+ (instancetype)EPSG900913projection
{
    //http://trac.osgeo.org/openlayers/wiki/SphericalMercator
    CMProjectedRect theBounds = (CMProjectedRect){
        (CMProjectedPoint){ -20037508.34, -20037508.34 },
        (CMProjectedSize){ 20037508.34 * 2, 20037508.34 * 2}
    };
    CMProjection *projection = [[CMProjection alloc]
                                initWithString:@"+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +no_defs"
                                      inBounds:theBounds];
    return projection;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"Illegal method call" reason:@"Use -initWithString:inBounds: instead" userInfo:nil];
}

- (id)initWithString:(NSString *)proj4String inBounds:(CMProjectedRect)projectedBounds
{
    self = [super init];
    if (!self)
        return nil;
    internalProjection = pj_init_plus([proj4String UTF8String]);
    _planetBounds = projectedBounds;
    return self;
}

- (void)dealloc
{
    if (internalProjection)
        pj_free(internalProjection);
}

- (CMProjectedPoint)coordinateToProjectedPoint:(CLLocationCoordinate2D)aLatLong
{
    projUV uv = { aLatLong.longitude * DEG_TO_RAD, aLatLong.latitude * DEG_TO_RAD };
    projUV result = pj_fwd(uv, internalProjection);
    CMProjectedPoint result_point = { result.u, result.v };
    return result_point;
}

@end
