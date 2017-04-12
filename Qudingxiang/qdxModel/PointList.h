

#import <Foundation/Foundation.h>

#import "qdxPoint.h"

@interface PointList: NSObject
@property (nonatomic,copy) NSString *count; //总条数
@property (nonatomic,copy) NSString *allpage; //总页数
@property (nonatomic,copy) NSString *curr; //当前页
@property (nonatomic,strong) NSMutableArray *pointArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end
