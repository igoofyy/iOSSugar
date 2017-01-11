//
//  HRHTTPManger.h
//  HRManger
//
//  Created by goofygao on 8/3/16.
//  Copyright © 2016 goofyy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRNetWorkingBlock.h"

@interface HRHTTPManger : AFHTTPSessionManager

+ (AFHTTPSessionManager *)manger;

/**
 *  POST请求
 *
 *  @param urlString    请求的url - 去除rootUrl
 *  @param parameters   参数
 *  @param responseKeys 返回的keys @[@"error",@"success"]
 *  @param autoRun      任务是否继续运行
 *  @param uploadFile   上传的文件，由于该APP只有图片上传，所以只设置图片上传
 *  @param progress     进度
 *  @param completion   完成后的闭包
 *
 *  @return 当前任务task
 */
+ (HRTask *)POST:(NSString *)urlString
      parameters:(NSDictionary *)parameters
     isEHRServer:(BOOL)isEHRServer
    responseKeys:(id)responseKeys
         autoRun:(BOOL)autoRun
      uploadFile:(UIImage *)image
        progress:(GFNetProcessBlock)progress
      completion:(GFNetCompletionBlock)completion;

/**
 *  POST请求
 *
 *  @param urlString    请求的url - 去除rootUrl
 *  @param parameters   参数
 *  @param responseKeys 返回的keys @[@"error",@"success"]
 *  @param autoRun      任务是否继续运行
 *  @param progress     进度
 *  @param completion   完成后的闭包
 *
 *  @return 当前任务task
 */
+ (HRTask *)GET:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                isEHRServer:(BOOL)isEHRServer
              responseKeys:(id)responseKeys
                   autoRun:(BOOL)autoRun
                  progress:(GFNetProcessBlock)progress
                completion:(GFNetCompletionBlock)completion;



/**
 下载文件

 @param urlString 下载链接
 @param paramer 参数
 @param progress 进度
 @param isEHRServer 是否是ehr
 @param filePath 文件存放路径
 @param autoRun 是否失败后自动运行
 @param completion 完成后的回调
 @return 任务
 */

+ (HRTask *)DOWNLOAD:(NSString *)urlString
             paramer:(NSDictionary *)paramer
            progress:(GFNetProcessBlock)progress
         isEHRServer:(BOOL)isEHRServer
            filePath:(NSString *)filePath
             autoRun:(BOOL)autoRun
          completion:(GFNetCompletionBlock)completion;

/**
 *  判断当前网络是否可用
 *
 *  @return BOOL
 */
+ (BOOL)isNetWorkFail;

@end
