//
//  LocalDBService.m
//  趣定向
//
//  Created by Air on 16/8/2.
//  Copyright © 2016年 Air. All rights reserved.
//

#import "LocalDBService.h"
#import "LocalSqlliteService.h"



@implementation LocalDBService
+ (void)LoadDb:(void (^)(NSDictionary *dict))block FailBlock:(void(^)(NSMutableArray *array))failBlock andWithLine:(NSString *)line_id andWithMyline:(NSString *)Myline_id{
    

    //使用离线数据
    NSString *cacheKey = [@"/MylineInfo" stringByAppendingString:Myline_id ];
    
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    //NSDictionary *res=[NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
    

    
    NSString *urlString = [hostUrl stringByAppendingString:loadDb];
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    //说明服务器返回的事JSON数据
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    //封装请求参数
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"line_id"] = line_id;
   
    __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dict = responseObject;
        
        [NSKeyedArchiver archiveRootObject:dict toFile:fileName];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSMutableArray *failArr = [[NSMutableArray alloc]init];
        [failArr addObject:error];
        if (failBlock) {
            failBlock(failArr);
        }
        
    }];
    
}



+ (NSDictionary *)CheckTask:(NSMutableDictionary *)param{
    
    NSMutableDictionary *resualt =  [[NSMutableDictionary alloc] initWithDictionary:param] ;
    
    NSString  *Myline_id = param[@"myline_id"];
    
    NSDictionary *dicMylineinfo= [self ReadMylineInfo:Myline_id];

    NSDictionary *DicMyline = [self ReadMyline:Myline_id];
    
    if(param[@"mac"]!=nil && ![param[@"mac"] isEqualToString:@""]){
        NSString *mac = [[NSString alloc] initWithFormat:@"%@",param[@"mac"]];
        
        if(mac.length == 12){
            mac =[[[[[[[[[[[mac substringWithRange:NSMakeRange(0,2)]  stringByAppendingString:@":" ]
            stringByAppendingString:[mac substringWithRange:NSMakeRange(2,2)]]  stringByAppendingString:@":" ]
            stringByAppendingString:[mac substringWithRange:NSMakeRange(4,2)]]
                 stringByAppendingString:@":" ]
            stringByAppendingString: [mac substringWithRange:NSMakeRange(6,2)]]
            stringByAppendingString:@":" ]
            stringByAppendingString:[mac substringWithRange:NSMakeRange(8,2)]]
            stringByAppendingString:@":" ]
            stringByAppendingString:[mac substringWithRange:NSMakeRange(10,2)]];
        }
        
          for(NSDictionary *infoDic in dicMylineinfo) {
              
              if([infoDic[@"point_id"] isEqualToString:mac] ||[infoDic[@"label"] isEqualToString:mac] )
              {
                  //找到点标
                  
                  bool isHistory =[self CheckHistory:Myline_id PointMap:infoDic[@"pintmap_id"]];
                  
                  if(isHistory){
                      //本线路本点标已经记录了
                      [resualt setValue:0 forKey:@"Code"];
                      [resualt setValue:@"已记录" forKey:@"Msg"];
                      return resualt ;
                  }
                  
                  
                      NSDictionary *pointquDic = infoDic[@"pointqumap"] ;
                      if([pointquDic isEqual:[NSNull null]]){
                          //无题通过
                          
                          [self PassChange:DicMyline PointMap:infoDic];
                          [resualt setValue:@"2" forKey:@"Code"];
                          [resualt setValue:@"Yes" forKey:@"Msg"];
                          return resualt ;
                       
                      }else{
                         //有题目刷新
                        [self ResetQuestion:Myline_id Dic:pointquDic];
                        [resualt setValue:@"1" forKey:@"Code"];
                        [resualt setValue:[self ReadQuestion:Myline_id] forKey:@"Msg"];
                           return resualt ;
                          //有题随机返回一条
                      }
              }
            
          }
        
        
    } else if(param[@"answer"]!=nil && ![param[@"answer"] isEqualToString:@""]){

        NSMutableDictionary *queDic = [[NSMutableDictionary alloc] initWithDictionary:[self ReadQuestion:Myline_id]];
        
        NSDictionary *pointmapDic = [[NSDictionary alloc] init];
       
        //根据题目找到点标
        for(NSDictionary *infoDic in dicMylineinfo) {
            
            if([infoDic[@"pointmap_id"] isEqualToString: queDic[@"pointmap_id"]])
            {
                 pointmapDic =infoDic;
                
            }
        }

     
        if([param[@"answer"] isEqualToString:queDic[@"question"][@"qkey"]]){
            
            [self PassChange:DicMyline PointMap:pointmapDic];
            [resualt setValue:@"2" forKey:@"Code"];
            [resualt setValue:@"Yes" forKey:@"Msg"];
            return resualt ;
            
        }else{
            
            NSDictionary *pointquDic = pointmapDic[@"pointqumap"];
            [self ResetQuestion:Myline_id Dic:pointquDic];
            [resualt setValue:@"1" forKey:@"Code"];
            [resualt setValue:[self ReadQuestion:Myline_id] forKey:@"Msg"];
            return resualt ;
            
        }
        
    }


    return resualt;
}

//-(void)sort:(NSMutableArray *)arr
//{
//    for (int i = 0; i<arr.count; i++) {
//        for (int j = 0; j<arr.count -i - 1; j++) {
//            if ([arr[j+1] integerValue] < [arr[j] integerValue]) {
//                int temp = [arr[j] integerValue];
//                arr[j] = arr[j+1];
//                arr[j+1] = [NSNumber numberWithInt:temp];
//            }
//        }
//    }
//}

+(bool) PassChange:(NSDictionary *)DicMyline PointMap:(NSDictionary *)infoDic
{

    
    [DicMyline setValue:infoDic[@"pointmap_id"] forKey:@"pointmap_id"];
    [DicMyline setValue:infoDic[@"pointmap_img"] forKey:@"img_url"];
    [DicMyline setValue:infoDic  forKey:@"pointmap"];
    
    if([infoDic[@"pindex"] intValue]>=998 ){
        
        [DicMyline setValue:@"3" forKey:@"mstatus_id"];
    }else{
        [DicMyline setValue:@"2" forKey:@"mstatus_id"];
    }
    
    NSMutableDictionary *pointDic = [[NSMutableDictionary alloc] init];
    [pointDic setValue:infoDic[@"point_name"] forKey:@"point_name"];
    
    
    //依次穿越修改点标
    
    int linetype_id = [DicMyline[@"line"][@"linetype_id"] intValue];
    if (linetype_id == 1) {
        NSMutableDictionary *pointD = DicMyline[@"point"];
        NSDictionary *dicMylineinfo= [self ReadMylineInfo:DicMyline[@"myline_id"]];
        
        for(NSDictionary *infoDic_2 in dicMylineinfo) {
            if([infoDic_2[@"pindex"] intValue] >[DicMyline[@"pointmap"][@"pindex"] intValue]){
                pointD[@"label"] = [NSString stringWithFormat:@"%@,%@",infoDic_2[@"point_id"],infoDic_2[@"label"]];
                pointD[@"point_name"] = infoDic_2[@"point_name"];
                break;
            }
        }
    }
    
    //修改历史记录
    NSMutableArray *history= DicMyline[@"history"];
    NSMutableDictionary *hisInfo = [[NSMutableDictionary alloc]init];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    hisInfo[@"edate"] = dateString;
    hisInfo[@"myline_id"] = DicMyline[@"myline_id"] ;
    
    NSMutableDictionary *pointInfo = [[NSMutableDictionary alloc]init];
    pointInfo[@"rssi"] =infoDic[@"rssi"];
    pointInfo[@"point_name"] = infoDic[@"point_name"];
    hisInfo[@"point"] = pointInfo;
    hisInfo[@"mylineinfo_id"] =@"0" ;
    hisInfo[@"point_id"] = infoDic[@"point_id"] ;
    hisInfo[@"pointmap_id"] = infoDic[@"pointmap_id"];
    hisInfo[@"score"] =@"0" ;
    [history addObject:hisInfo];
    
    [self WriteMyline:DicMyline];
    NSDictionary *historyDic = DicMyline[@"history"];
    [self WriteHistory:DicMyline[@"myline_id"] Dic:historyDic];
    
  //  NSLog(@"=========== %@",historyDic);
    return YES;
    
}

//检查记录历史
+ (Boolean )CheckHistory:(NSString *)Myline_id PointMap:(NSString *)pointmap_id{
    
    NSString *cacheKey = [@"/MylineHistory" stringByAppendingString:Myline_id ];
    
    NSString *fileHistory =[accountFile stringByAppendingString:cacheKey];
    NSDictionary *resHistory=[NSKeyedUnarchiver unarchiveObjectWithFile:
                              fileHistory];
    
    for (NSDictionary *infoDic in resHistory) {
        if([infoDic[@"pointmap_id"] isEqualToString: pointmap_id]){
            return YES;
        }
        
    }
    return NO;
}

//写记录历史
+ (void )WriteHistory:(NSString *)Myline_id Dic:(NSDictionary *)dict{
    
    NSString *cacheKey = [@"/MylineHistory" stringByAppendingString:Myline_id ];
    
    NSString *fileHistory =[accountFile stringByAppendingString:cacheKey];
    
    [NSKeyedArchiver archiveRootObject:dict toFile:fileHistory];
 
}


+ (NSDictionary *)ReadMylineInfo:(NSString *)Myline_id{
    
    NSString *cacheKey = [@"/MylineInfo" stringByAppendingString:Myline_id ];
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    NSDictionary *res=[NSKeyedUnarchiver unarchiveObjectWithFile:
                       fileName];
    
    return res;
}
//查线路信息
+ (NSDictionary *)ReadMyline:(NSString *)Myline_id{
    
    NSString *cacheKey = [@"/Myline" stringByAppendingString:Myline_id ];
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    NSDictionary *res=[NSKeyedUnarchiver unarchiveObjectWithFile:
                              fileName];
    return res;
}

//写线路信息
+ (void)WriteMyline:(NSDictionary *)dict{
    
    NSString *cacheKey = [@"/Myline" stringByAppendingString:dict[@"myline_id"]];
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    [NSKeyedArchiver archiveRootObject:dict toFile:fileName];
    
}


//查题目
+ (NSDictionary *)ReadQuestion:(NSString *)Myline_id{
    
    NSString *cacheKey = [@"/MylineQuestion" stringByAppendingString:Myline_id ];
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    NSDictionary *res=[NSKeyedUnarchiver unarchiveObjectWithFile:
                       fileName];
 
    return res;
}

//写新题目
+ (void)ResetQuestion:(NSString *)Myline_id Dic:(NSDictionary *)dict{
    
    NSString *cacheKey = [@"/MylineQuestion" stringByAppendingString:Myline_id ];
    
    NSString *fileName =[accountFile stringByAppendingString:cacheKey];
    
    
    
    NSDictionary *queDic =[self ReadQuestion:Myline_id];
    
    int offset = arc4random()%dict.count;
    
    int row = 0;

    for(NSDictionary *questionDic in dict){
       
        if(row == offset){
            if(dict.count > 1 && ![questionDic[@"pointqumap_id"] isEqualToString:queDic[@"pointqumap_id"]]){
                
                
              [NSKeyedArchiver archiveRootObject:questionDic toFile:fileName];
                
            }
        }
        if(dict.count ==1){ //只要一题目时
           [NSKeyedArchiver archiveRootObject:questionDic toFile:fileName];
        }
        row++;
        
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    NSString *htmlPath = [accountFile stringByAppendingString:@"/question.html"];
    //if([fileManager fileExistsAtPath:htmlPath])
    NSDictionary *qudic = [self ReadQuestion:Myline_id];
    NSString   *question = qudic[@"question"][@"question_name"];
    NSData *htmlData = [question dataUsingEncoding:NSUTF8StringEncoding];
  
    [fileManager createFileAtPath:htmlPath contents:htmlData attributes:nil];
    
    
}
+ (void)UploadHistory:(NSString *)Myline_id
{
  
    
    
    NSDictionary *MylineDic= [self ReadMyline:Myline_id];
    NSDictionary *res= MylineDic[@"history"];
    for(NSDictionary *hisInfo in res){
        
         NSString *mylineinfo_id = hisInfo[@"mylineinfo_id"];
          // NSLog(@"hisInfo  %@",hisInfo);
        if (mylineinfo_id !=nil && [mylineinfo_id intValue] == 0) {
            
         
           NSString *time = hisInfo[@"edate"];
           NSString *myline_id = hisInfo[@"myline_id"]  ;
           NSString *pointmap_id =  hisInfo[@"pointmap_id"];
              NSLog(@"time  %@",time);
           NSString *urlString = [hostUrl stringByAppendingString:uploadHistory];
           AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
           //说明服务器返回的事JSON数据
           mgr.responseSerializer = [AFJSONResponseSerializer serializer];
         //封装请求参数
           NSMutableDictionary *params = [NSMutableDictionary dictionary];
           params[@"time"] = time;
           params[@"myline_id"] = myline_id;
           params[@"pointmap_id"] = pointmap_id;
    
           __block NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
           [mgr POST:urlString parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
        
           } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                dict = responseObject;
               int code = [dict[@"Code"] intValue];
               NSMutableDictionary *Msg = dict[@"Msg"];
               if(code == 1){
               //修改历史记录
                    //NSString *myline_id =Msg[@"myline_id"];
                    NSString *pointmap_id =Msg[@"pointmap_id"];
                    NSString *score =Msg[@"score"];
                    NSString *mylineinfo_id =Msg[@"mylineinfo_id"];
                   
                   
                   
                   
                   
                    for(NSDictionary *theInfo in res){
                        
                        if([theInfo[@"pointmap_id"] isEqualToString:pointmap_id]){
                            [theInfo setValue:score forKey:@"score"];
                            [theInfo setValue:mylineinfo_id forKey:@"mylineinfo_id"];
                            [self WriteMyline:MylineDic];

                        }
                        
                    }
                   
        
               }
        
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        
        }];
        
        }
    }
    
}



@end
