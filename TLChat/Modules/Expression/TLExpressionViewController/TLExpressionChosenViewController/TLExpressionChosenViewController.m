//
//  TLExpressionChosenViewController.m
//  TLChat
//
//  Created by 李伯坤 on 16/4/4.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLExpressionChosenViewController.h"
#import "TLExpressionSearchViewController.h"
#import "TLSearchController.h"
#import "TLExpressionGroupModel+ChosenRequest.h"
#import "TLExpressionHelper.h"
#import "ZZExpressionChosenAngel.h"
#import "TLExpressionDetailViewController.h"

typedef NS_ENUM(NSInteger, TLExpressionChosenSectionType) {
    TLExpressionChosenSectionTypeBanner,
    TLExpressionChosenSectionTypeRec,
    TLExpressionChosenSectionTypeChosen,
};

@interface TLExpressionChosenViewController () <UISearchBarDelegate>

@property (nonatomic, assign) NSInteger pageIndex;

/// 列表
@property (nonatomic, strong) UITableView *tableView;
/// 列表管理器
@property (nonatomic, strong) ZZExpressionChosenAngel *tableViewAngel;
/// 请求队列
@property (nonatomic, strong) ZZFLEXRequestQueue *requestQueue;
/// 搜索
@property (nonatomic, strong) TLSearchController *searchController;

@end

@implementation TLExpressionChosenViewController

- (void)loadView
{
    [super loadView];
    
    [self p_loadUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [TLUIUtility hiddenLoading];
}

#pragma mark - # Requests
- (void)requestDataIfNeed
{
    if (self.requestQueue.isRuning) {
        return;
    }
    self.requestQueue = [[ZZFLEXRequestQueue alloc] init];
    [self.requestQueue addRequestModel:self.bannerRequestModel];
    [self.requestQueue addRequestModel:self.recommentRequestModel];
    [self.requestQueue addRequestModel:[self listRequestModelWithPageIndex:1]];
    [TLUIUtility showLoading:nil];
    [self.requestQueue runAllRequestsWithCompleteAction:^(NSArray *data, NSInteger successCount, NSInteger failureCount) {
        [TLUIUtility hiddenLoading];
    }];
}

- (void)requestRetry:(UIButton *)sender
{
    [super requestRetry:sender];
    [self requestDataIfNeed];
}

#pragma mark - # Event Action
- (void)didSelectedExpressionGroup:(TLExpressionGroupModel *)groupModel
{
    TLExpressionDetailViewController *detailVC = [[TLExpressionDetailViewController alloc] init];
    [detailVC setGroup:groupModel];
    PushVC(detailVC);
}

- (void)startDownloadExpressionGroup:(TLExpressionGroupModel *)groupModel
{
//    groupModel.status = TLExpressionGroupStatusDownloading;
//    TLExpressionProxy *proxy = [[TLExpressionProxy alloc] init];
//    [proxy requestExpressionGroupDetailByGroupID:group.gId pageIndex:1 success:^(id data) {
//        group.data = data;
//        [[TLExpressionHelper sharedHelper] downloadExpressionsWithGroupInfo:group progress:^(CGFloat progress) {
//
//        } success:^(TLExpressionGroupModel *group) {
//            group.status = TLExpressionGroupStatusLocal;
//            NSInteger index = [self.data indexOfObject:group];
//            if (index < self.data.count) {
//                [self.tableView reloadData];
//            }
//            BOOL ok = [[TLExpressionHelper sharedHelper] addExpressionGroup:group];
//            if (!ok) {
//                [TLUIUtility showErrorHint:[NSString stringWithFormat:@"表情 %@ 存储失败！", group.name]];
//            }
//        } failure:^(TLExpressionGroupModel *group, NSString *error) {
//
//        }];
//    } failure:^(NSString *error) {
//        [TLUIUtility showErrorHint:[NSString stringWithFormat:@"\"%@\" 下载失败: %@", group.name, error]];
//    }];
}

#pragma mark - # Private Methods
- (void)p_loadUI
{
    /// 初始化列表
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.zz_make.backgroundColor([UIColor whiteColor])
    .separatorStyle(UITableViewCellSeparatorStyleNone)
    .tableHeaderView(self.searchController.searchBar).tableFooterView([UIView new])
    .estimatedRowHeight(0).estimatedSectionFooterHeight(0).estimatedSectionHeaderHeight(0);
    [self.view addSubview:self.tableView];
    
    /// 初始化列表管理器
    self.tableViewAngel = [[ZZExpressionChosenAngel alloc] initWithHostView:self.tableView];
    
    /// 初始化基本模块
    self.tableViewAngel.addSection(TLExpressionChosenSectionTypeBanner);
    self.tableViewAngel.addSection(TLExpressionChosenSectionTypeRec);
    self.tableViewAngel.addSection(TLExpressionChosenSectionTypeChosen);
}

#pragma mark - # Getter
- (TLSearchController *)searchController
{
    if (!_searchController) {
        _searchController = [TLSearchController createWithResultsContrllerClassName:NSStringFromClass([TLExpressionSearchViewController class])];
        [_searchController.searchBar setPlaceholder:LOCSTR(@"搜索表情")];
    }
    return _searchController;
}

- (ZZFLEXRequestModel *)bannerRequestModel
{
    @weakify(self);
    ZZFLEXRequestModel *requestModel = [ZZFLEXRequestModel requestModelWithTag:TLExpressionChosenSectionTypeBanner requestAction:^(ZZFLEXRequestModel *requestModel) {
        [TLExpressionGroupModel requestExpressionChosenBannerSuccess:^(id successData) {
            [requestModel executeRequestCompleteMethodWithSuccess:YES data:successData];
        } failure:^(id failureData) {
            [requestModel executeRequestCompleteMethodWithSuccess:NO data:failureData];
        }];
    } requestCompleteAction:^(ZZFLEXRequestModel *requestModel) {
        @strongify(self);
        if (!self) return;
        self.tableViewAngel.sectionForTag(TLExpressionChosenSectionTypeBanner).clear();
        if (requestModel.success) {
            self.tableViewAngel.addCell(@"TLExpressionBannerCell").toSection(requestModel.tag).withDataModel(requestModel.data);
        }
        else {
            [TLUIUtility showErrorHint:requestModel.data];
        }
        [self.tableView reloadData];
    }];
    return requestModel;
}

- (ZZFLEXRequestModel *)recommentRequestModel
{
    @weakify(self);
    ZZFLEXRequestModel *requestModel = [ZZFLEXRequestModel requestModelWithTag:TLExpressionChosenSectionTypeRec requestAction:^(ZZFLEXRequestModel *requestModel) {
        [TLExpressionGroupModel requestExpressionRecommentListSuccess:^(id successData) {
            [requestModel executeRequestCompleteMethodWithSuccess:YES data:successData];
        } failure:^(id failureData) {
            [requestModel executeRequestCompleteMethodWithSuccess:NO data:failureData];
        }];
    } requestCompleteAction:^(ZZFLEXRequestModel *requestModel) {
        @strongify(self);
        if (!self) return;
        self.tableViewAngel.sectionForTag(requestModel.tag).clear();
        if (requestModel.success) {
            self.tableViewAngel.setHeader(@"TLExpressionTitleView").withDataModel(LOCSTR(@"推荐表情")).toSection(requestModel.tag);
            self.tableViewAngel.addCells(@"TLExpressionCell").withDataModelArray(requestModel.data).toSection(requestModel.tag).selectedAction(^ (id data) {
                @strongify(self);
                [self didSelectedExpressionGroup:data];
            })
            .eventAction(^ id(NSInteger eventType, id data) {
                @strongify(self);
                [self startDownloadExpressionGroup:data];
                return nil;
            });
        }
        [self.tableView reloadData];
    }];
    return requestModel;
}

- (ZZFLEXRequestModel *)listRequestModelWithPageIndex:(NSInteger)pageIndex
{
    self.pageIndex = pageIndex;
    @weakify(self);
    ZZFLEXRequestModel *requestModel = [ZZFLEXRequestModel requestModelWithTag:TLExpressionChosenSectionTypeChosen requestAction:^(ZZFLEXRequestModel *requestModel) {
        @strongify(self);
        if (!self) return;
        requestModel.userInfo = @{@"pageIndex" : @(pageIndex)};
        if (pageIndex == 1) {
            [self.tableView tt_removeLoadMoreFooter];
        }
        [TLExpressionGroupModel requestExpressionChosenListByPageIndex:pageIndex success:^(id successData) {
            [requestModel executeRequestCompleteMethodWithSuccess:YES data:successData];
        } failure:^(id failureData) {
            [requestModel executeRequestCompleteMethodWithSuccess:NO data:failureData];
        }];
    } requestCompleteAction:^(ZZFLEXRequestModel *requestModel) {
        @strongify(self);
        if (!self) return;
        if ([requestModel.userInfo[@"pageIndex"] integerValue] == 1) {
            self.tableViewAngel.sectionForTag(requestModel.tag).clear();
        }
        if (requestModel.success) {
            if ([requestModel.userInfo[@"pageIndex"] integerValue] == 1) {
                [self.tableView tt_addLoadMoreFooterWithAction:^{
                    @strongify(self);
                    [[self listRequestModelWithPageIndex:self.pageIndex + 1] executeRequestMethod];
                }];
                
                if ([requestModel.data count] > 0) {
                    self.tableViewAngel.setHeader(@"TLExpressionTitleView").withDataModel(LOCSTR(@"更多精选")).toSection(requestModel.tag);
                }
            }
            
            if ([requestModel.data count] > 0) {
                self.tableViewAngel.addCells(@"TLExpressionCell").withDataModelArray(requestModel.data).toSection(requestModel.tag).selectedAction(^ (id data) {
                    @strongify(self);
                    [self didSelectedExpressionGroup:data];
                })
                .eventAction(^ id(NSInteger eventType, id data) {
                    @strongify(self);
                    [self startDownloadExpressionGroup:data];
                    return nil;
                });
                [self.tableView tt_endLoadMore];
            }
            else {
                [self.tableView tt_endLoadMoreWithNoMoreData];
            }
        }
        else {
            [self.tableView tt_endLoadMore];
            [self showErrorViewWithTitle:requestModel.data];
        }
        [self.tableView reloadData];
    }];
    return requestModel;
}

@end