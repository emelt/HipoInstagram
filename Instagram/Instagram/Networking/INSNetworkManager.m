//
//  INSNetworkManager.m
//  Instagram
//
//  Created by Emel Topaloglu on 07/11/2015.
//  Copyright © 2015 Emel Topaloglu. All rights reserved.
//

#import "INSNetworkManager.h"
#import "AFHTTPSessionManager.h"
#import "INSRequest+StringHelpers.h"
#import "NSString+INSAdditions.h"

@interface INSNetworkManager()

@property (strong, nonatomic) NSURL *baseURL;
@property (strong, nonatomic) AFHTTPSessionManager *networkingManager;
@property (assign, nonatomic) BOOL logsEnabled;

@end

@implementation INSNetworkManager

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super init];
    if (self)
    {
        _baseURL = url;
        _networkingManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
        _networkingManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _networkingManager.responseSerializer = [AFJSONResponseSerializer serializer];
#if DEBUG
        _logsEnabled = true;
#endif
    }
    
    return self;
}

#pragma mark - Public Methods

- (NSString *)sendRequest:(INSRequest *)request
               completion:(INSRequestCompletion)completion
{
    NSMutableURLRequest *urlRequest = [self.networkingManager.requestSerializer requestWithMethod:[request requestTypeString]
                                                                                        URLString:[self fullURLForRequest:request]
                                                                                       parameters:request.additionalParameters
                                                                                            error:nil];
    if (!request)
    {
        if (completion)
        {
            completion([NSError errorWithDomain:kINSNetworkingErrorDomain code:INSNetworkErrorInvalid userInfo:nil], nil);
        }
        
        return nil;
    }
    
    if (self.logsEnabled)
    {
        NSLog(@"\n--- INSNetwork \n Sending:\n %@ (%@) \n\nHeaders: %@\n\n", urlRequest.URL, urlRequest.HTTPMethod, [urlRequest allHTTPHeaderFields]);
    }
    
    __block NSURLSessionDataTask * dataTask = [self.networkingManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if(error == nil)
        {
            if (self.logsEnabled)
            {
                NSLog(@"\n--- INSNetwork success: %@ \n\nHeaders: %@\n\nData: %@\n\n", httpResponse.URL, httpResponse.allHeaderFields, responseObject);
            }
            
            completion(nil, responseObject);
        }
        else
        {
            if (self.logsEnabled)
            {
                NSLog(@"\n--- INSNetwork fail: %@ \n\nHeaders: %@\n\nError: %@\n\n", httpResponse.URL, httpResponse.allHeaderFields, error);
            }
            
            completion(error, nil);
        }
    }];
    
    [dataTask resume];
    
    return [NSString stringWithFormat:@"%li",(unsigned long)dataTask.taskIdentifier];
}

#pragma mark - Helpers

- (NSString *)fullURLForRequest:(INSRequest *)request
{
    NSString *fullURL = self.baseURL.absoluteString;
    
    if (request.relativeURL)
    {
        fullURL = [NSString urlPathWithComponents:@[fullURL, request.relativeURL]];
    }
    
    return fullURL;
}


@end
