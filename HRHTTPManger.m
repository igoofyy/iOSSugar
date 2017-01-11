//
//  HRHTTPManger.m
//  HRManger
//
//  Created by goofygao on 8/3/16.
//  Copyright © 2016 goofyy. All rights reserved.
//

#import "HRHTTPManger.h"
#import "HRDBManger.h"

#define REQUEST_TIME_OUT 5
@implementation HRHTTPManger

static HRHTTPManger *_instace;


+ (id)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace = [super allocWithZone:zone];
    });
    return _instace;
}


+ (HRHTTPManger *)manger {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instace                                           = [[self alloc] init];
        _instace.requestSerializer                         = [AFJSONRequestSerializer serializer];
        [_instace.requestSerializer setValue:@"text/plain" forHTTPHeaderField:@"Content-Type"];
        _instace.requestSerializer.timeoutInterval         = REQUEST_TIME_OUT;
        _instace.responseSerializer                        = [AFJSONResponseSerializer serializer];
        _instace.responseSerializer.acceptableContentTypes = [_instace.responseSerializer.acceptableContentTypes setByAddingObject: @"text/html"];
        [self configHttpSession];
    });
    return _instace;

}

- (id)copyWithZone:(NSZone *)zone
{
    return _instace;
}

+ (BOOL)isNetWorkFail {
    return ![[AFNetworkReachabilityManager sharedManager] isReachable];
}

/**
 *  配置HTTP 设置session
 */
+ (void)configHttpSession {
    id userSessionObject = [HRDBManger cacheObjectWithKey:GHR_DB_LOGIN_SESSION_KEY];
    if (userSessionObject != nil) {
        [self configHttpCookie:userSessionObject];
    }
}


+ (NSString *)fullUrlString:(NSString *)urlString isEHRServer:(BOOL)isEHRServer{
    NSString *urlRoot  = isEHRServer ? [HRUsers shareUserInfo].ehr_url : HRAPIRootBsseURL;
    GFLog(@"API请求地址----%@",[urlRoot stringByAppendingString:urlString]);
    GFLog(@"请求服务器----%@",isEHRServer ? @"EHR服务器" : @"GHR服务器");
    NSString *orginUrl = [urlRoot stringByAppendingString:urlString];
    return [orginUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (AFSecurityPolicy*)customSecurityPolicy:(BOOL)isEHRServer
{
    
    AFSecurityPolicy *securityPolicy        = [AFSecurityPolicy policyWithPinningMode: AFSSLPinningModeCertificate];
    NSString *certificatePath               = [[NSBundle mainBundle] pathForResource:isEHRServer ? @"https-ehr" : @"https"  ofType:@"cer"];
    NSData *certificateData                 = [NSData dataWithContentsOfFile:certificatePath];

    NSSet *certificateSet                   = [[NSSet alloc] initWithObjects:certificateData, nil];
    [securityPolicy setPinnedCertificates:certificateSet];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName      = NO;

    return securityPolicy;
}

+ (void)configHttpCookie:(BOOL)isEHRServer {
    
    id object = isEHRServer ? [HRUsers shareUserInfo].ehrcookie : [HRUsers shareUserInfo].ghrcookie;
    if (object) {
        [[HRHTTPManger manger].requestSerializer setValue:object forHTTPHeaderField:@"Cookie"];

    }
    GFLog(@"COOKIE信息-%@",object);
}

+ (HRTask *)POST:(NSString *)urlString
                parameters:(NSDictionary *)parameters
               isEHRServer:(BOOL)isEHRServer
              responseKeys:(id)responseKeys
                   autoRun:(BOOL)autoRun
                uploadFile:(UIImage *)image
                  progress:(GFNetProcessBlock)progress
                completion:(GFNetCompletionBlock)completion; {
    AFHTTPSessionManager *manager = [HRHTTPManger manger];
    [self configHttpCookie:isEHRServer];
    GFLog(@"请求参数 = %@",parameters);
    NSURLSessionTask *task = [manager POST:[self fullUrlString:urlString isEHRServer:isEHRServer] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
    if (image == nil) return;
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
        [formData appendPartWithFileData:imageData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    }
    progress:^(NSProgress * _Nonnull uploadProgress) {
         if (progress) progress(uploadProgress);
     }
     success:^(HRTask *task, id response)
     {
         [self saveCookieToLocal:urlString isEHRServer:isEHRServer];
         
         GFLog(@"%@=POST请求-返回值%@",[self fullUrlString:urlString isEHRServer:isEHRServer],response);
         if ([response isKindOfClass:[NSArray class]]) {
             return !completion ? : completion(YES, response);
         }
         if ([response isKindOfClass:[NSDictionary class]]) {
                 
             if (responseKeys == nil) {
                 return !completion ? : completion(YES, response);
             }
                 
             if ([responseKeys isKindOfClass:[NSString class]]) {
                 return !completion ? : completion(YES, response[responseKeys]);
             }
                 
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             if ([responseKeys isKindOfClass:[NSArray class]]) {
                 for (id key in responseKeys) {
                     [dict setObject:response[key] ? : @"" forKey:key];
                 }
             } else if ([responseKeys isKindOfClass:[NSDictionary class]]) {
                 for (id key in [responseKeys allKeys]) {
                     [dict setObject:response[key] forKey:responseKeys[key]];
                 }
             }
             return !completion ? : completion(YES, dict);
             
         }
     } failure:^(HRTask * task, NSError *error) {
         !completion ? : completion(NO, error);
     }];
    if(autoRun) [task resume];
    return task;
}

+ (nullable HRTask *)GET:(NSString *)urlString
      parameters:(NSDictionary *)parameters
     isEHRServer:(BOOL)isEHRServer
    responseKeys:(id)responseKeys
         autoRun:(BOOL)autoRun
        progress:(GFNetProcessBlock)progress
      completion:(GFNetCompletionBlock)completion; {
    AFHTTPSessionManager *manager = [HRHTTPManger manger];
    GFLog(@"请求参数 = %@",parameters);
    GFLog(@"GET请求-请求地址%@",[self fullUrlString:urlString isEHRServer:isEHRServer]);
    [self configHttpCookie:isEHRServer];
    NSURLSessionTask *task = [manager GET:[self fullUrlString:urlString isEHRServer:isEHRServer] parameters:parameters progress:progress success:^(HRTask *task, id response)
     {
         GFLog(@"GET请求-请求参数%@",parameters);
         GFLog(@"%@=GET请求-返回值%@",[self fullUrlString:urlString isEHRServer:isEHRServer],response);
         
         [self saveCookieToLocal:urlString isEHRServer:isEHRServer];
         
         if ([response isKindOfClass:[NSArray class]]) {
             
             return !completion ? : completion(YES, response);
         }
         if ([response isKindOfClass:[NSDictionary class]]) {
                 
             if (responseKeys == nil) {
                 
                 return !completion ? : completion(YES, response);
             }
                 
             if ([responseKeys isKindOfClass:[NSString class]]) {
                 return !completion ? : completion(YES, response[responseKeys]);
             }
                 
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
             if ([responseKeys isKindOfClass:[NSArray class]]) {
                 for (id key in responseKeys) {
                     [dict setObject:response[key] ? : @"" forKey:key];
                 }
             } else if ([responseKeys isKindOfClass:[NSDictionary class]]) {
                 for (id key in [responseKeys allKeys]) {
                     [dict setObject:response[key] forKey:responseKeys[key]];
                 }
             }
            !completion ? : completion(YES, dict);
        }
         
     } failure:^(HRTask * task, NSError *error) {
         if (completion) completion(NO, error);
     }];
    if(autoRun) [task resume];
    return task;
}

+ (void)saveCookieToLocal:(NSString *)urlString isEHRServer:(BOOL)isEHRServer {
    NSURL *url = [NSURL URLWithString:[self fullUrlString:urlString isEHRServer:isEHRServer]];
    NSArray *cookieStorage = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    NSDictionary *cookieHeaders = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieStorage];
    if (cookieHeaders.count != 0) {
        id cookie = [cookieHeaders objectForKey:@"Cookie"];
        [HRNsuerDefaultManger saveObject:cookie withKey:isEHRServer ? EHR_NSUSERDEFAULT_LOGIN_SESSION_KEY : GHR_NSUSERDEFAULT_LOGIN_SESSION_KEY];
    }
}

+ (HRTask *)DOWNLOAD:(NSString *)urlString
             paramer:(NSDictionary *)paramer
            progress:(GFNetProcessBlock)progress
         isEHRServer:(BOOL)isEHRServer
             filePath:(NSString *)filePath
             autoRun:(BOOL)autoRun
          completion:(GFNetCompletionBlock)completion {
    AFHTTPSessionManager *manager = [HRHTTPManger manger];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self fullUrlString:urlString isEHRServer:YES]]];
    NSURLSessionTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if(progress) progress(downloadProgress);
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return [NSURL fileURLWithPath:filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        error == nil ? completion(YES,filePath) : completion(NO,error);
    }];
    if(autoRun) [task resume];
    return task;
}

@end
