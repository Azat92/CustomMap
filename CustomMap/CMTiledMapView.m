//
//  CMMapView.m
//  CustomMap
//
//  Created by Azat Almeev on 07.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMTiledMapView.h"

@interface CMTiledMapView ()
@property (nonatomic, retain, readonly) CATiledLayer *tiledLayer;
@property (nonatomic, retain) id <CMMapSource> tileSource;
@end

@implementation CMTiledMapView
@synthesize tileSource;

- (id)initWithFrame:(CGRect)frame tilesSource:(id <CMMapSource>)mapSource
{
    self = [super initWithFrame:frame];
    if (self) {
        self.tileSource = mapSource;
        self.tiledLayer.levelsOfDetailBias = tileSource.maxZoom;
        self.tiledLayer.levelsOfDetail = tileSource.maxZoom;
    }
    return self;
}

+ (Class)layerClass
{
    return [CATiledLayer class];
}

- (CATiledLayer *)tiledLayer
{
    return (CATiledLayer *)self.layer;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGRect rect = CGContextGetClipBoundingBox(context);
    UIGraphicsPushContext(context);
    int x = rect.origin.x / rect.size.width;
    int y = rect.origin.y / rect.size.height;
    int zoom = log2f(256 / rect.size.width);
    
    UIImage *tileImage = [self.tileSource tileForX:x y:y andZoom:zoom completion:^(BOOL success) {
        if (success)
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.layer setNeedsDisplayInRect:rect];
            });
    }];
    if (!tileImage)
        tileImage = [UIImage imageNamed:@"notile"];
    [tileImage drawInRect:rect];
    UIGraphicsPopContext();
}

@end
