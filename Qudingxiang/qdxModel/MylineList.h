

#import <Foundation/Foundation.h>

#import "Myline.h"

@interface MylineList: NSObject
@property (nonatomic,copy) NSString *count; //总条数
@property (nonatomic,copy) NSString *allpage; //总页数
@property (nonatomic,copy) NSString *curr; //当前页
@property (nonatomic,strong) NSMutableArray *mylineArray;//列表
-(id)initWithDic:(NSDictionary *) infoDict;
@end