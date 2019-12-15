//
//  ViewController.m
//  MusicKit
//
//  Created by Daniel Kuntz on 4/27/17.
//  Copyright © 2017 Venture Media Labs. All rights reserved.
//

#import "ViewController.h"
#import <SSZipArchive/SSZipArchive.h>
#import "MusicKitApp-Swift.h"

#include <mxml/parsing/ScoreHandler.h>
#include <mxml/SpanFactory.h>
#include <mxml/EventFactory.h>
#include <lxml/lxml.h>

#include <iostream>
#include <fstream>


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *musicSheet;
@property (strong, nonatomic) VMKPageScoreDataSource *PageScoreDataSource;
@property (strong, nonatomic) VMKPageScoreLayout *PageScoreLayout;
@property (atomic) mxml::PageScoreGeometry *scoreGeometry;
@property (atomic) mxml::dom::Score *score;
@property (atomic) Conductor *conductor;

@end

@implementation ViewController

std::unique_ptr<mxml::dom::Score> loadMXL(NSString* filePath) {
    NSArray* cachePathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* cachePath = [cachePathArray firstObject];
    NSString* filename = [[filePath lastPathComponent] stringByDeletingPathExtension];
    NSString* destPath = [cachePath stringByAppendingPathComponent:filename];

    NSError* error;
    BOOL success = [SSZipArchive unzipFileAtPath:filePath
                                   toDestination:destPath
                                       overwrite:YES
                                        password:nil
                                           error:&error
                                        delegate:nil];
    if (error)
        NSLog(@"Error unzipping: %@", error);
    if (!success) {
        NSLog(@"Failed to unzip %@", filePath);
        return std::unique_ptr<mxml::dom::Score>();
    }

    NSFileManager* fileManager = [[NSFileManager alloc] init];
    NSArray* paths = [fileManager contentsOfDirectoryAtPath:destPath error:NULL];
    NSString* xmlFile = nil;
    for (NSString* file in paths) {
        if ([file hasSuffix:@".xml"]) {
            xmlFile = file;
            break;
        }
    }
    if (xmlFile == nil) {
        NSLog(@"Archive does not contain an xml file: %@", filePath);
        return std::unique_ptr<mxml::dom::Score>();
    }

    try {
        NSString* xmlPath = [destPath stringByAppendingPathComponent:xmlFile];
        std::ifstream is([xmlPath UTF8String]);

        mxml::parsing::ScoreHandler handler;
        lxml::parse(is, [filename UTF8String], handler);
        return handler.result();
    } catch (mxml::dom::InvalidDataError& error) {
        NSLog(@"Error loading score '%@': %s", filePath, error.what());
        return std::unique_ptr<mxml::dom::Score>();
    }
}

std::unique_ptr<mxml::dom::Score> loadXML(NSString* filePath) {
    mxml::parsing::ScoreHandler handler;
    std::ifstream is([filePath UTF8String]);
    lxml::parse(is, [filePath UTF8String], handler);
    return handler.result();
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString* path = [mainBundle pathForResource:@"Game_of_Thrones_Easy_piano" ofType:@"mxl"];
    
    // Parse input file
    std::unique_ptr<mxml::dom::Score> score;
    if ([path hasSuffix:@".xml"]) {
        score = loadXML(path);
    } else if ([path hasSuffix:@".mxl"]) {
        score = loadMXL(path);
    } else {
        std::cerr << "File extension not recognized, assuming compressed MusicXML (.mxl).\n";
        score = loadMXL(path);
    }

    if (!score || score->parts().empty() || score->parts().front()->measures().empty())
        return ;

    // Generate geometry
    _score = score.release();
    _scoreGeometry = new mxml::PageScoreGeometry(*_score, 300);
    
    _PageScoreDataSource = [[VMKPageScoreDataSource alloc] init];
    _PageScoreDataSource.scoreGeometry = _scoreGeometry;
    _musicSheet.dataSource = _PageScoreDataSource;
    
    _PageScoreLayout = [[VMKPageScoreLayout alloc] init];
    _PageScoreLayout.scoreGeometry = _scoreGeometry;
    _musicSheet.collectionViewLayout = _PageScoreLayout;
    
    
    mxml::ScoreProperties scoreProperties(*_score, mxml::ScoreProperties::LayoutType::Page);

    mxml::EventFactory factory(*_score, scoreProperties);
    auto events = factory.build();
    
    _conductor = [[Conductor alloc] init];
    for (auto& event : events->events()) {
        if(event.onNotes().size() == 0) continue;
        [_conductor addWithNoteNumber:event.onNotes().front()->midiNumber() position:event.wallTime() duration:event.wallTimeDuration()];
        
    }
    [_conductor play];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
