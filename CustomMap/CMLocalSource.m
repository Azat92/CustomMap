//
//  CMLocalSource.m
//  CustomMap
//
//  Created by Azat Almeev on 10.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMLocalSource.h"

@implementation CMLocalSource
- (CGSize)tileSize
{
    return CGSizeMake(256, 256);
}

- (int)maxZoom
{
    return 5;
}

- (UIImage *)tileForX:(int)x y:(int)y andZoom:(int)zoom completion:(void (^)(BOOL success))completion
{
    zoom--;
    x++;
    y++;
    return [UIImage imageNamed:[NSString stringWithFormat:@"x=%d y=%d z=%d.png", x, y, zoom]];
}
@end
