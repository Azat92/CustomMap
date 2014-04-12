//
//  CMProjection.h
//  CustomMap
//
//  Created by Azat Almeev on 09.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMProjection : NSObject
@property (nonatomic, readonly) CMProjectedRect planetBounds;
+ (instancetype)EPSG900913projection;
- (instancetype)initWithString:(NSString *)proj4String inBounds:(CMProjectedRect)projectedBounds;
- (CMProjectedPoint)coordinateToProjectedPoint:(CLLocationCoordinate2D)aLatLong;
@end
