

#import <Foundation/Foundation.h>

#import "Line.h"

@interface LineList: NSObject
@property (nonatomic,copy) NSString *Code; //状态码
@property (nonatomic,strong) NSMutableArray *lineArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end
