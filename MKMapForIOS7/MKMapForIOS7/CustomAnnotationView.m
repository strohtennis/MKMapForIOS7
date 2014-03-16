//
//  AnnotationPinView.m
//  MKMapForIOS7
//
//  Created by Eric Stroh on 9/1/13.
//  CapTech Consulting
//  Copyright (c) 2013 Eric Stroh. All rights reserved.
//

#import "CustomAnnotationView.h"


@implementation CustomAnnotationView

-(id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    UIImage *pinImg = [UIImage imageNamed:@"blueStar"];
    self.image = pinImg;
    self.canShowCallout = YES;
    self.centerOffset = CGPointMake(1, -16);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];

    [button setImage:[UIImage imageNamed:@"callout"] forState:UIControlStateNormal];
    [button addTarget:self  action:@selector(buttonPressed:)     forControlEvents:UIControlEventTouchUpInside];
    self.leftCalloutAccessoryView = button;
    return self;
}

- (IBAction)buttonPressed:(id)sender {
    NSLog(@"callout Button has been pressed");
}




@end
