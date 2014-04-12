//
//  CMViewController.m
//  CustomMap
//
//  Created by Azat Almeev on 07.04.14.
//  Copyright (c) 2014 Azat Almeev. All rights reserved.
//

#import "CMViewController.h"
#import "CMMapView.h"

@implementation MyAnnotation
- (NSString *)title
{
    return @"Казанский Университет";
}

- (NSString *)subtitle
{
    return @"420000, Казань, ул. Кремлевская, 18";
}

- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(55.790408, 49.121435);
}

@end

@interface CMViewController () <UITextFieldDelegate, CMMapViewDelegate, MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet CMMapView *mapView;
//@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *placemarkLabel;
@property (weak, nonatomic) IBOutlet UIView *searchPane;
@end

@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mapView.delegate = self;
    self.placemarkLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
    self.searchPane.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //CMMapView
    [self.mapView moveToStartPosition];

//    //MKMapView
//    self.mapView.showsUserLocation = YES;
//    self.mapView.mapType = MKMapTypeHybrid;
//    [self.mapView addAnnotation:[[MyAnnotation alloc]init]];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    //CMMapView
    [self.mapView searchByQuery:textField.text];
    
    return YES;
}

#pragma mark - Map View Delegate
- (void)mapView:(CMMapView *)mapView didFailUpdateUserLocation:(NSString *)errorString
{
    self.placemarkLabel.text = errorString;
}

- (void)mapView:(CMMapView *)mapView didUpdatedUserLocation:(NSString *)newLocation
{
    self.placemarkLabel.text = newLocation;
}

@end
