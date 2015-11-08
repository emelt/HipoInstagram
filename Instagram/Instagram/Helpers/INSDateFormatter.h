//
//  INSDateFormatter.h
//  Instagram
//
//  Created by Emel Topaloglu on 08/11/2015.
//  Copyright © 2015 Emel Topaloglu. All rights reserved.
//

@interface INSDateFormatter : NSObject

+ (INSDateFormatter *)sharedFormatter;

- (NSDate *)dateFromUTCTime:(NSTimeInterval)utcTime;

@end
