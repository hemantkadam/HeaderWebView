//
//  EmailView.m
//  HeaderWebView
//
//  Created by Catalina Turlea on 4/13/15.
//  Copyright (c) 2015 Catalina Turlea. All rights reserved.
//

#import "EmailView.h"

@interface EmailView () <UIScrollViewDelegate>

@property (nonatomic, weak) UIView *innerHeaderView;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, getter = isFullScreen) BOOL fullScreen;

@property (nonatomic) CGFloat previousHeaderHeight;

@end

@implementation EmailView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self createHeaderView];
    
    [self.webView setScalesPageToFit:YES];
    
    [self.webView.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionInitial context:nil];
    
    [self.webView.scrollView setDelegate:self];
    
    [self.webView.scrollView setShowsVerticalScrollIndicator:NO];
}

#pragma mark -
#pragma mark - NSKeyObserving

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // Update the frame of the header view so that it scrolls with the webview content
    CGRect newFrame = self.headerView.frame;
    newFrame.origin.y = -CGRectGetMinY([self convertRect:self.innerHeaderView.frame toView:self.webView.scrollView]);
    [self.headerView setFrame:newFrame];
    
    BOOL fullScreen = (newFrame.origin.y < 0) || [self isFullScreen];
    
    // Call the delegate for the full screen
    [self.fullScreenDelegate emailView:self showFullScreen:fullScreen];
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // This is used to avoid weird behaviour when frame changes on full screen
    [self setFullScreen:(scrollView.zoomScale >= 1)];
}

#pragma mark -
#pragma mark - Custom methods

- (void)createHeaderView {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 60)];
    
    [self.webView.scrollView addSubview:headerView];
    [self setInnerHeaderView:headerView];
    
    [self addSubview:self.headerView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.previousHeaderHeight == CGRectGetHeight(self.headerView.frame)) {
        return;
    }
    for (UIView *subview in self.webView.scrollView.subviews) {
        CGRect newFrame = subview.frame;
        if ([subview isEqual:self.innerHeaderView]) {
            continue;
        }
        
        newFrame.origin.y = CGRectGetHeight(self.headerView.frame);
        [subview setFrame:newFrame];
    }
    
    [self setPreviousHeaderHeight:CGRectGetHeight(self.headerView.frame)];
}

- (void)dealloc {
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}


@end
